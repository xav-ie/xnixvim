// git-heat-churn: per-line "hotness" (churn) for a file.
//
// Walks first-parent history oldest -> newest and, for each version of the
// file, diffs it against the previous version. A per-line edit counter follows
// lines as hunks insert/delete around them: a line replaced N times accrues
// heat ~N, a line added once and never touched stays at 1 (even if it is the
// most recent change). This measures churn, not recency.
//
// Output: one unsigned integer per line of the file at HEAD, newline-separated.
// Exit non-zero (with nothing on stdout) when the path is untracked / not in a
// repo, so the caller can simply skip drawing.

use std::io::{self, Write};
use std::ops::Range;
use std::path::PathBuf;
use std::process::ExitCode;

use imara_diff::intern::InternedInput;
use imara_diff::{diff, Algorithm, Sink};

// Rebuilds the heat vector for the "after" side of a single diff. imara-diff
// reports changed regions in order; everything else is unchanged and copied
// straight through, preserving each surviving line's accumulated heat.
struct HeatSink<'a> {
    old: &'a [u32],
    new: Vec<u32>,
    bi: usize, // next index in `old` not yet copied
}

impl<'a> Sink for HeatSink<'a> {
    type Out = Vec<u32>;

    fn process_change(&mut self, before: Range<u32>, after: Range<u32>) {
        let bstart = before.start as usize;
        let bend = before.end as usize;

        // unchanged lines between the previous hunk and this one
        self.new.extend_from_slice(&self.old[self.bi..bstart]);

        // hottest value in the region being replaced, carried forward so a
        // repeatedly-rewritten region keeps climbing rather than resetting
        let mut carry = 0u32;
        for &h in &self.old[bstart..bend] {
            if h > carry {
                carry = h;
            }
        }

        let removed = bend - bstart;
        let added = (after.end - after.start) as usize;
        // pure insertion -> brand new (cold) line; replacement -> carry + 1
        let val = if removed == 0 { 1 } else { carry + 1 };
        self.new.resize(self.new.len() + added, val);

        self.bi = bend;
    }

    fn finish(mut self) -> Self::Out {
        self.new.extend_from_slice(&self.old[self.bi..]);
        self.new
    }
}

fn churn_step(old_heat: &[u32], old_text: &str, new_text: &str) -> Vec<u32> {
    let input = InternedInput::new(old_text, new_text);
    // Histogram groups multi-line rewrites the way git's code diffs do; the
    // resulting per-line attribution tracks `git log -L` closely.
    diff(
        Algorithm::Histogram,
        &input,
        HeatSink {
            old: old_heat,
            new: Vec::new(),
            bi: 0,
        },
    )
}

fn run(arg: &str) -> Result<Vec<u32>, Box<dyn std::error::Error>> {
    let abs = std::fs::canonicalize(arg)?;
    let dir = abs.parent().unwrap_or(&abs);

    let repo = gix::discover(dir)?;
    let workdir = repo
        .work_dir()
        .ok_or("repository has no working tree")?
        .canonicalize()?;
    let rel: PathBuf = abs.strip_prefix(&workdir)?.to_path_buf();
    // git uses forward slashes in path specs
    let rel_str = rel
        .components()
        .map(|c| c.as_os_str().to_string_lossy())
        .collect::<Vec<_>>()
        .join("/");

    // first-parent history, newest -> oldest, then reversed
    let head = repo.head_id()?;
    let mut commits = Vec::new();
    for info in repo
        .rev_walk(Some(head.detach()))
        .first_parent_only()
        .all()?
    {
        commits.push(info?.id);
    }
    commits.reverse();

    // resolve the blob id of the file at each commit by walking the tree
    // directly (much cheaper than rev-parsing a spec string per commit);
    // collapse runs where the file did not change, and drop commits where it
    // did not yet exist
    let mut blob_ids = Vec::new();
    let mut buf = Vec::new();
    for commit in &commits {
        let tree = repo.find_commit(*commit)?.tree()?;
        if let Some(entry) = tree.lookup_entry_by_path(&rel_str, &mut buf)? {
            // skip commits where this path was a directory (tree), not a file
            if entry.mode().is_blob() {
                let id = entry.oid().to_owned();
                if blob_ids.last() != Some(&id) {
                    blob_ids.push(id);
                }
            }
        }
    }

    if blob_ids.is_empty() {
        return Err("file is not tracked".into());
    }

    // fold the diffs: "" -> v1 -> v2 -> ... -> HEAD
    let mut heat: Vec<u32> = Vec::new();
    let mut prev_text = String::new();
    for id in blob_ids {
        let data = repo.find_object(id)?.try_into_blob()?.take_data();
        let text = String::from_utf8_lossy(&data).into_owned();
        heat = churn_step(&heat, &prev_text, &text);
        prev_text = text;
    }

    Ok(heat)
}

fn main() -> ExitCode {
    let arg = match std::env::args().nth(1) {
        Some(a) => a,
        None => {
            eprintln!("usage: git-heat-churn <file>");
            return ExitCode::FAILURE;
        }
    };

    match run(&arg) {
        Ok(heat) => {
            let mut out = String::with_capacity(heat.len() * 3);
            for h in heat {
                out.push_str(&h.to_string());
                out.push('\n');
            }
            let _ = io::stdout().write_all(out.as_bytes());
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("git-heat-churn: {e}");
            ExitCode::FAILURE
        }
    }
}
