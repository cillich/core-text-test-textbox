# core-text-test-textbox
Small project to learn about Core Text and creating text boxes using Core Text

# How to Use the App
The text box is editable, but it does not automatically pull up a keyboard. In order to write in the text box you should either use a simulator and use your computer's keyboard, or attach a physical keyboard to your iPad.

Click the "Left Align", "Center Align", and "Right Align" buttons to switch through the different alignments.

# The Problem

I wasn't sure how to get Core Text to handle different text alignments. I attempted three different options. You can find these options in the `TextBoxTest.swift` file. Uncomment which ever option you want to test.

## Alignment Option 1: Paragraph Styling

This is the most straight forward and widely documented way of setting text alignment. You set the text alignment as a paragraph styling for the attributed string. Then you create a framesetter which creates a frame that can be drawn into the view.

## Alignment Option 2: Manually Creating Line Breaks

This seems like it will work, but it doesn't. Eventhough the attributed string has the text alignment as a paragraph style, it would seem that the typesetter and CTLine/CTTypesetterSuggestLineBreak do not know about this attribute.

## Alignment Option 3: Manually Creating Line Breaks with Flush

Essentially Option 2, with the added bonus of CTLineGetPenOffsetForFlush. This is used to get the offset to "draw flush text". A 0.0 flush would be left aligned, 0.5 flush would be center aligned, and 1.0 flush would be right aligned. The other values seem to be varying degrees of center flush.
