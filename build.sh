#!/bin/bash

echo
echo "--------------------------------------"
echo "         ArrowOS 13.0 Buildbot        "
echo "                  by                  "
echo "                ponces                "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_build_arrow
BD=$HOME/builds

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://github.com/ArrowOS/android_manifest -b arrow-13.0
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/arrow.xml
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying prerequisite patches"
    bash $BL/apply-patches.sh $BL prerequisite
    echo

    echo "--> Applying TrebleDroid patches"
    cd device/phh/treble
    cp $BL/arrow.mk .
    bash generate.sh arrow
    cd ../../..
    bash $BL/apply-patches.sh $BL trebledroid
    echo

    echo "--> Applying personal patches"
    bash $BL/apply-patches.sh $BL personal
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVariant() {
    echo "--> Building treble_arm64_bvN"
    export ARROW_GAPPS=false
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

buildGappsVariant() {
    echo "--> Building treble_arm64_bgN"
    export ARROW_GAPPS=true
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bgN.img
    echo
}

buildVndkliteVariant() {
    echo "--> Building treble_arm64_bvN-vndklite"
    cd sas-creator
    sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bvN.img
    cp s.img $BD/system-treble_arm64_bvN-vndklite.img
    sudo rm -rf s.img d tmp
    cd ..
    echo
}

buildVndkliteGappsVariant() {
    echo "--> Building treble_arm64_bgN-vndklite"
    cd sas-creator
    sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bgN.img
    cp s.img $BD/system-treble_arm64_bgN-vndklite.img
    sudo rm -rf s.img d tmp
    cd ..
    echo
}

generatePackages() {
    echo "--> Generating packages"
    xz -cv $BD/system-treble_arm64_bvN.img -T0 > $BD/Arrow-v13.0-arm64-ab-UNOFFICIAL-$BUILD_DATE-VANILLA.img.xz
    xz -cv $BD/system-treble_arm64_bgN.img -T0 > $BD/Arrow-v13.0-arm64-ab-gapps-UNOFFICIAL-$BUILD_DATE-GAPPS.img.xz
    xz -cv $BD/system-treble_arm64_bvN-vndklite.img -T0 > $BD/Arrow-v13.0-arm64-ab-vndklite-UNOFFICIAL-$BUILD_DATE-VANILLA.img.xz
    xz -cv $BD/system-treble_arm64_bgN-vndklite.img -T0 > $BD/Arrow-v13.0-arm64-ab-vndklite-UNOFFICIAL-$BUILD_DATE-GAPPS.img.xz
    rm -rf $BD/system-*.img
    echo
}

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
buildVariant
buildGappsVariant
buildVndkliteVariant
buildVndkliteGappsVariant
generatePackages

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
