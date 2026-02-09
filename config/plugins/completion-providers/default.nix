{
  lib,
  config,
  ...
}:
{
  imports = [
    ./augment.nix
    ./minuet-ai-nvim.nix
    ./cursortab-nvim.nix
  ];

  # Mutually exclusive AI completion provider option
  # null = disabled, "minuet", "cursortab", or "augment"
  options.programs.ai-completion-provider = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "augment"
        "minuet"
        "cursortab"
      ]
    );
    default = null;
    description = "AI completion provider to use. Only one can be active at a time.";
  };

  config = {
    # Enable the selected provider
    programs.augment.enabled = config.programs.ai-completion-provider == "augment";
    programs.minuet-ai.enabled = config.programs.ai-completion-provider == "minuet";
    programs.cursortab.enabled = config.programs.ai-completion-provider == "cursortab";
  };
}
