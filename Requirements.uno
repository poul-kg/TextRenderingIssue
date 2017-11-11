using Uno;
using Uno.Collections;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;
using Uno.UX;

[Require("Cocoapods.Podfile.Target", "pod 'Mapbox-iOS-SDK', '~> 3.6'")]

[UXGlobalModule]
public class SpeechModule : NativeModule
{
    static readonly SpeechModule _instance;
    
    public SpeechModule()
    {

    }
}