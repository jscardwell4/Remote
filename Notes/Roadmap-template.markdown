##Agenda:

###Quick Fix:
- <s>Get `ButtonGroupConfigurationDelegate` working again</s>

###Short Term:
- <s>Fix ConfigurationDelegate issue</s>
- <s>Fix panel tucking in `ButtonGroupView`</s>
- <s>Change behavior of `ButtonGroupView` panels to stop disabling/enabling their buttons</s>
- <s>Undo model changes to `Image` subclasses and design implementation that makes more logical sense</s>
- <s>Refactor `Image` and subclasses by adding "Gallery" prefix to class names</s>
- <s>Introduce implementation for caching objects to reduce memory storage and usage with `Image` and subclasses</s>
- <s>Finish `LabelEditingViewController` and `IconEditingViewController`</s>
- <s>Change "remote system bar" behavior to be less annoying</s>
- Add `ComponentDevice` specific remotes and provide easy access
- Finish `ButtonEditingViewController`
- Polish `RemoteEditingViewController` and `ButtonGroupEditingViewController`
- Slider response via custom thumb image with value text
- <s>Add convenience macros from Erica Sadun's book</s>
- Make styled highlight color stand out more
- Make `ButtonView` stretchable
- Add background color editable in `ButtonEditingViewController`

###Long Term:
- Animated button response as shown in Erica Sadun's book
- Give icons set names and categories
- Replace touch event handling with gestures in `ButtonView`?
- Replace device dependent geometry code with code that obtains dimensions from the `UIScreen` class
- Use Instruments to check memory management strategies
- Repeating commands by holding touch (i.e. volume up and down)
- Implement caching and make sure it works properly for images, colors, fonts
- Create `PopUpButtonGroupView`
- Create `TimeButtonView`
- Create "Gesture Pad" that receives touch drawn gestures to execute commands (similar to Apple's Remote App)

###Sounding Board:
- Possible uses for block style notification callbacks?
- Possible improvements with block based dictionary enumartions?
- Add debug tracing via prefix file macro as described in Sadun's book
- Over the air ad hoc distribution? "TestFlight"?
- Runtime compatibility checks?
- Monitor notifications via overridden `respondsToSelector:`?
- Register additional objects for `UIApplication` notifications?
