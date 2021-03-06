//
//  AttributedLabel_ExampleAppDelegate.m
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "AttributedLabel_ExampleAppDelegate.h"
#import "NSAttributedString+Attributes.h"

@implementation AttributedLabel_ExampleAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [self.window makeKeyAndVisible];

	visitedLinks = [[NSMutableSet alloc] init];
	
	/* Don't forget to add the CoreText framework in your project ! */
	[self fillLabel1];
	[self fillLabel2];
	[self fillLabel3];
	
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application {
	[visitedLinks release];
}




/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 1 : Simple text with bold and custom link.
/////////////////////////////////////////////////////////////////////////////



#define TXT_BEGIN "Hello World! How are you? Don't forget to "
#define TXT_LINK "share your food"
#define TXT_END "!"

-(IBAction)fillLabel1 {
	NSString* txt = @ TXT_BEGIN TXT_LINK TXT_END; // concat the 3 (#define) constant parts in a single NSString
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
	// for those calls we don't specify a range so it affects the whole string
	[attrStr setFont:[UIFont systemFontOfSize:18]];
	[attrStr setTextColor:[UIColor grayColor]];

	// now we only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];	
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label1.attributedText = attrStr;
	// and add a link to the "share your food!" text
	[label1 addCustomLink:[NSURL URLWithString:@"http://www.foodreporter.net"] inRange:[txt rangeOfString:@TXT_LINK]];
	 
	// Use the "Justified" alignment
	label1.textAlignment = UITextAlignmentJustify;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.	
}

-(IBAction)makeWorldBold
{
	/**(3)** (... later ...) Modify again the existing string *******/
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [label1.attributedText mutableCopy];
	// Modify the the font of "World!" to bold, 24pt
	[mas setFont:[UIFont boldSystemFontOfSize:24] range:NSMakeRange(6,6)];
	// Affect back the attributed string to the label
	label1.attributedText = mas;
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
}






/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 2 : Alignment, Size, etc
/////////////////////////////////////////////////////////////////////////////




-(IBAction)fillLabel2 {
	// Suppose you already have set the following properties of the myAttributedLabel object in InterfaceBuilder:
	// - 'text' set to "Hello World!"
	// - fontSize set to 12, text color set to gray
	
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [label2.attributedText mutableCopy];
	// and only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];
	
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label2.attributedText = attrStr;
	// Use the "Justified" alignment
	label2.textAlignment = UITextAlignmentCenter;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
	
	[attrStr release];
}


-(IBAction)changeHAlignment {
	label2.textAlignment = (label2.textAlignment+1) % 4;
}

-(IBAction)changeVAlignment {
	label2.centerVertically = !label2.centerVertically;
}

-(IBAction)changeSize {
	CGRect r = label2.frame;
	r.size.width = 500 - r.size.width; // switch between 200 and 300px
	label2.frame = r;
}




/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 3 : Using Links for navigation in your app
/////////////////////////////////////////////////////////////////////////////


-(IBAction)fillLabel3 {
	NSRange linkRange = [label3.text rangeOfString:@"internal navigation"];
	[label3 addCustomLink:[NSURL URLWithString:@"user://tom1362"] inRange:linkRange];
	label3.centerVertically = YES;
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Visited Links
/////////////////////////////////////////////////////////////////////////////

-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline {
	if ([visitedLinks containsObject:link.URL]) {
		// Visited link
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternDot;
		return [UIColor purpleColor];
	} else {
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternSolid;
		return [UIColor blueColor];
	}
}
-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo {
	[visitedLinks addObject:linkInfo.URL];
	[attributedLabel setNeedsDisplay];
	
	if ([[linkInfo.URL scheme] isEqualToString:@"user"]) {
		// We use this arbitrary URL scheme to handle custom actions
		// So URLs like "user://xxx" will be handled here instead of opening in Safari.
		// Note: in the above example, "xxx" is the 'host' of the URL

		NSString* user = [linkInfo.URL host];
		NSString* msg = [NSString stringWithFormat:@"Here you should display the profile of user %@ on a new screen.",user];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"User Profile" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		// Prevent the URL from opening as we handled here manually instead
		return NO;
	} else {
		// Execute the default behavior, which is opening the URL in Safari.
		return YES;
	}
}

-(IBAction)resetVisitedLinks {
	[visitedLinks removeAllObjects];
	[label1 setNeedsDisplay];
	[label2 setNeedsDisplay];
	[label3 setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
