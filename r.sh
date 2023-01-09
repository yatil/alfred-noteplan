#!/usr/bin/env zsh
# fake npm scripts hahaha

about () { #: show help & commands
    NAME='alfred-noteplan-fts'
    echo "$NAME script runner"
    echo "Commands:"
    cat r.sh | sed -nr 's/^(.*) \(\).* #: (.*)$/  \1\t\2/p' | expand -20
}

build:licenses () { #: Get all the licenses from pubspec.lock
    dart-pubspec-licenses-lite -i pubspec.lock | grep -v null > LICENSES
}

build:dart () { #: Build the version for the current architecture
    dart compile exe bin/noteplan_fts.dart -o "workflow/noteplan_fts-$(uname -m)"
}

build:icons () { #: Build the icns file from iconsets
    echo "not implemented yet."
}

build:script () { #: Copy the script part from the workflow.sh into info.plist
    cp workflow/info.plist workflow/info.plist.bak
    SCRIPT=`cat test/workflow.sh | sed -e 's/"/\\\\"/g'`
    /usr/libexec/PlistBuddy -c "Set :objects:1:config:script $SCRIPT" workflow/info.plist
}

build:workflow () { #: Zip the workflow folder into release/dist folder
    echo "not implemented yet."
}

build () { #: Run the whole build
    build:licenses
    build:icons
    build:dart
    build:workflow
}

version () { #: get the workflow version
    defaults read "$(pwd)/workflow/info" version
}

dev:link () { #: link the WIP version to Alfred
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts-dart/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts-dart;
}

dev:unlink () { #: remove the WIP version link from Alfred
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts-dart;
}

dev:dumplist () { #: dump the info.plist into plist.txt
    /usr/libexec/PlistBuddy -c 'print: ":name"' workflow/info.plist > plist.txt
}

test () { #: run tests
    zsh test/test.sh
}

if [[ $# > 0 ]]; then
    script=`shift 1`
    $script "$@"
else
    about
fi