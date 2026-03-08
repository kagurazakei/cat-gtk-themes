{ stdenvNoCC, lib }:

let
  # -----------------------
  # GTK themes
  # -----------------------
  gtkThemes = builtins.attrNames (builtins.readDir ./themes);

  gtkThemePackages = lib.genAttrs gtkThemes (
    name:
    stdenvNoCC.mkDerivation {
      pname = name;
      version = "nightly";

      src = ./themes/${name};

      dontBuild = true;

      installPhase = ''
        mkdir -p $out/share/themes
        cp -r * $out/share/themes/
      '';

      meta = with lib; {
        description = "GTK theme: ${name}";
        platforms = lib.platforms.linux;
        license = lib.licenses.mit;
      };
    }
  );

  # -----------------------
  # Icon themes
  # -----------------------
  iconFiles = builtins.attrNames (builtins.readDir ./icons);

  iconThemePackages = lib.genAttrs iconFiles (
    name:
    let
      path = ./icons/${name};
    in
    stdenvNoCC.mkDerivation {
      pname = name;
      version = "nightly";

      src = path;

      dontBuild = true;

      installPhase = ''
        mkdir -p $out/share/icons

        if [ -d "$src" ]; then
          cp -r "$src"/* $out/share/icons/
        elif [ -f "$src" ] && [[ "$src" == *.tar.gz ]]; then
          tar -xzf "$src" -C $out/share/icons
        fi
      '';

      meta = with lib; {
        description = "Icon theme: ${name}";
        platforms = lib.platforms.linux;
        license = lib.licenses.mit;
      };
    }
  );

  # -----------------------
  # Default derivation: all GTK + all icons
  # -----------------------
  allThemesAndIcons = stdenvNoCC.mkDerivation {
    pname = "cat-gtk-themes-all";
    version = "nightly";

    dontBuild = true;

    src = ./.;

    installPhase = ''
      mkdir -p $out/share/themes
      mkdir -p $out/share/icons

      # Copy all GTK themes
      if [ -d themes ]; then
        cp -r themes/* $out/share/themes/
      fi

      # Copy/extract all icons
      if [ -d icons ]; then
        for f in icons/*; do
          if [ -d "$f" ]; then
            cp -r "$f" $out/share/icons/
          elif [ -f "$f" ] && [[ "$f" == *.tar.gz ]]; then
            tar -xzf "$f" -C $out/share/icons
          fi
        done
      fi
    '';

    meta = with lib; {
      description = "All GTK themes and icon themes";
      platforms = lib.platforms.linux;
      license = lib.licenses.mit;
    };
  };

in
# Expose per-theme, per-icon, and default-all
gtkThemePackages
// iconThemePackages
// {
  default = allThemesAndIcons;
}
