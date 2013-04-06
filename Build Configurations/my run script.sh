# first clean the project
xcodebuild clean -target MSKit
xcodebuild clean -target MSKit-i386

if test -e $PROJECT_DIR/MSKit.framework;
then
rm -r $PROJECT_DIR/MSKit.framework
fi

xcodebuild build -target MSKit
xcodebuild build -target MSKit-i386

cp -R $PROJECT_DIR/build/Release-iphoneos/MSKit.framework $PROJECT_DIR/

lipo -output $PROJECT_DIR/MSKit.framework/Versions/A/MSKit -create $PROJECT_DIR/build/Release-iphoneos/MSKit.framework/Versions/A/MSKit $PROJECT_DIR/build/Release-iphonesimulator/MSKit-i386.framework/Versions/A/MSKit-i386
