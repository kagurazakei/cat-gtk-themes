{ stdenvNoCC, lib }:

let
  # GTK themes: copy each folder under themes/
  gtkThemes = builtins.attrNames (builtins.readDir ./themes);

  gtkThemePackages = lib.genAttrs gtkThemes (
    name:
    stdenvNoCC.mkDerivation {
      pname = name;
      version = "nightly";

      src = ./themes/${name};

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

  # Icon themes: detect folders and tar.gz files
  iconFiles = builtins.attrNames (builtins.readDir ./icons);

  iconThemePackages = lib.genAttrs iconFiles (
    name:
    let
      path = ./icons/${name};
    in
    stdenvNoCC.mkDerivation {
      pname = name;
      version = "1.0";

      src = path;

      installPhase = ''
        mkdir -p $out/share/icons

        if [ -d "$src" ]; then
          # It's a folder
          cp -r "$src"/* $out/share/icons/
        elif [ -f "$src" ] && [[ "$src" == *.tar.gz ]]; then
          # It's a tar.gz archive
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

in
gtkThemePackages // iconThemePackages
