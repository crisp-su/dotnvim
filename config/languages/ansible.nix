{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    ansible
    ansible-lint
  ];

  plugins.lsp.servers.ansiblels = {
    enable = true;
    package = pkgs.ansible-language-server;
    packageFallback = true;
  };

  filetype = {
    pattern = {
      ".*/playbooks/.*%.ya?ml" = "yaml.ansible";
      ".*/roles/.-/tasks/.*%.ya?ml" = "yaml.ansible";
      ".*/roles/.-/handlers/.*%.ya?ml" = "yaml.ansible";
      ".*/roles/.-/vars/.*%.ya?ml" = "yaml.ansible";
      ".*/roles/.-/defaults/.*%.ya?ml" = "yaml.ansible";
      ".*/roles/.-/meta/.*%.ya?ml" = "yaml.ansible";
    };
  };
}
