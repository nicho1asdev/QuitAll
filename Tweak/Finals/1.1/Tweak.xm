//import shit
#import <Cephei/HBPreferences.h>


//settings
bool enabled = true;
bool leftButtonPlacement = false;
bool darkStyle = false;
bool dontQuitNowPlaying = true;
bool dontQuitNavigation = true;
//variable shit
bool addedButton = false;
bool transparantButton = false;

BOOL centerButtonPlacement = NO;
BOOL useXmark = NO;

UIView *buttonView;
UIButton *button;
UILabel *fromLabel;

@interface SBSwitcherAppSuggestionContentView: UIView
@end

@interface SBDisplayItem: NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;               //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBMediaController : NSObject
@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
@end



//interfaces
@interface SBMainSwitcherViewController: UIViewController
+ (id)sharedInstance;
-(id)recentAppLayouts;
-(void)_rebuildAppListCache;
-(void)_destroyAppListCache;
-(void)_removeCardForDisplayIdentifier:(id)arg1 ;
-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBAppLayout:NSObject
@property (nonatomic,copy) NSDictionary * rolesToLayoutItemsMap;                                         //@synthesize rolesToLayoutItemsMap=_rolesToLayoutItemsMap - In the implementation block
@end

@interface SBRecentAppLayouts: NSObject
+ (id)sharedInstance;
-(id)_recentsFromPrefs;
-(void)remove:(SBAppLayout* )arg1;
-(void)removeAppLayouts:(id)arg1 ;
@end

%group tweak

%hook SBSwitcherAppSuggestionContentView
-(void)didMoveToWindow {
	%orig;
	if (!addedButton) {
		//create base view
		buttonView = [[UIView alloc] init];
		if (!centerButtonPlacement) {
			buttonView.frame = CGRectMake(300.0, 12.0, 60.0, 26.0);
			buttonView.clipsToBounds = true;
			buttonView.tag = 7;
			buttonView.alpha = 0.60;
			buttonView.layer.cornerRadius = 12;
		}
		else {
			buttonView.frame = CGRectMake(self.frame.size.width / 2 - 37.5, self.frame.size.height - 117, 75, 75);
			buttonView.clipsToBounds = YES;
			buttonView.tag = 7;
			buttonView.alpha = 0.6;
			buttonView.layer.cornerRadius = 37.5;
		}

		//create smooth smooth blur
		UIBlurEffect *blurEffect;
		if (darkStyle) {
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		} else {
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		}
		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		blurEffectView.frame = buttonView.bounds;
		blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[buttonView addSubview:blurEffectView];

		//add subview to main view
		[self insertSubview:buttonView atIndex:10];

		// View constraints
		if (!centerButtonPlacement) {
			buttonView.translatesAutoresizingMaskIntoConstraints = false;
			[buttonView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12].active = YES;
			if (leftButtonPlacement) {
				[buttonView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:15].active = YES;
			} else {
				[buttonView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-18].active = YES;
			}
			[buttonView.widthAnchor constraintEqualToConstant:57.0].active = YES;
			[buttonView.heightAnchor constraintEqualToConstant:25.0].active = YES;
		}

		//create a button for inside the view
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self
				action:@selector(buttonClicked:)
		forControlEvents:UIControlEventTouchUpInside];
		button.frame = buttonView.frame;
		if (@available(iOS 13.0, *)) {
			if (useXmark) [button setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:[UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge]] forState:UIControlStateNormal];
		}
		button.tintColor = [UIColor blackColor];
		[buttonView addSubview:button];
		[self insertSubview:button atIndex:12];

		button.userInteractionEnabled = YES;

		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleQuitLongPress)];
		longPress.minimumPressDuration = 1.0;
		[button addGestureRecognizer:longPress];


		//button constraints
		button.translatesAutoresizingMaskIntoConstraints = false;
		[button.topAnchor constraintEqualToAnchor:buttonView.topAnchor constant:0].active = YES;
		[button.bottomAnchor constraintEqualToAnchor:buttonView.bottomAnchor constant:0].active = YES;
		[button.leftAnchor constraintEqualToAnchor:buttonView.leftAnchor constant:0].active = YES;
		[button.rightAnchor constraintEqualToAnchor:buttonView.rightAnchor constant:0].active = YES;


		//add label to button
		if (!useXmark) {
			UIFont * customFont = [UIFont fontWithName:@"Arial-BoldMT" size:12.5]; //custom font
			fromLabel = [[UILabel alloc]initWithFrame:buttonView.bounds];
			fromLabel.text = @"Clear";
			fromLabel.font = customFont;
			fromLabel.textAlignment = NSTextAlignmentCenter;
			fromLabel.tag = 7;
			fromLabel.textColor = [UIColor whiteColor];

			[self insertSubview:fromLabel atIndex:11];

			//label constraints
			fromLabel.translatesAutoresizingMaskIntoConstraints = false;
			[fromLabel.topAnchor constraintEqualToAnchor:buttonView.topAnchor constant:0].active = YES;
			[fromLabel.bottomAnchor constraintEqualToAnchor:buttonView.bottomAnchor constant:0].active = YES;
			[fromLabel.leftAnchor constraintEqualToAnchor:buttonView.leftAnchor constant:0].active = YES;
			[fromLabel.rightAnchor constraintEqualToAnchor:buttonView.rightAnchor constant:0].active = YES;

			//set the alpha to 0 for fading in
			fromLabel.alpha = 0;
		}
		else button.alpha = 0;
		buttonView.alpha = 0;


		[UIView animateWithDuration:0.5 animations:^ {
			buttonView.alpha = 1;
			if (useXmark) button.alpha = 1;
			else fromLabel.alpha = 1;

		} completion:^(BOOL finished) {
		}];

		addedButton = true;

	} else if (addedButton && transparantButton) {
		[UIView animateWithDuration:0.3 animations:^ {
				buttonView.alpha = 0.6;
				if (useXmark) button.alpha = 1;
				else fromLabel.alpha = 1;

			}];
			transparantButton = false;
	}

}

%new
- (void)handleQuitLongPress {
	// id one = @1;

	//remove the apps
	UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] init];

	if (@available(iOS 13.0, *)) [impact impactOccurredWithIntensity:UIImpactFeedbackStyleRigid];

	SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
		NSArray *items = mainSwitcher.recentAppLayouts;
				for(SBAppLayout *item in items) {
					// SBDisplayItem *itemz = [item.rolesToLayoutItemsMap objectForKey:one];
					// NSString *bundleID = itemz.bundleIdentifier;

					[mainSwitcher _deleteAppLayout:item forReason:1];
				}

	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if (@available(iOS 13.0, *)) [impact impactOccurredWithIntensity:UIImpactFeedbackStyleRigid];
	});
}

%new
-(void) buttonClicked:(UIButton*)sender {
	id one = @1;

	UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] init];

	if (@available(iOS 13.0, *)) [impact impactOccurredWithIntensity:UIImpactFeedbackStyleMedium];

	//remove the apps
	SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
    NSArray *items = mainSwitcher.recentAppLayouts;
        for(SBAppLayout * item in items) {
					SBDisplayItem *itemz = [item.rolesToLayoutItemsMap objectForKey:one];
					NSString *bundleID = itemz.bundleIdentifier;
					NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];

					if (dontQuitNowPlaying && dontQuitNavigation) {
						if (![bundleID isEqualToString: nowPlayingID] && ![bundleID isEqualToString:@"com.google.Maps"] && ![bundleID isEqualToString:@"com.apple.Maps"] && ![bundleID isEqualToString:@"com.waze.iphone"]) {
							[mainSwitcher _deleteAppLayout:item forReason: 1];

						}
					} else if (!dontQuitNowPlaying && dontQuitNavigation) {
						if (![bundleID isEqualToString:@"com.google.Maps"] || ![bundleID isEqualToString:@"com.apple.Maps"] || ![bundleID isEqualToString:@"com.waze.iphone"]) {
							[mainSwitcher _deleteAppLayout:item forReason: 1];

						}
					} else if (dontQuitNowPlaying && !dontQuitNavigation) {
						if (![bundleID isEqualToString: nowPlayingID] ) {
							[mainSwitcher _deleteAppLayout:item forReason: 1];

						}
					} else {
						[mainSwitcher _deleteAppLayout:item forReason: 1];
					}
        }

	//hide the button
		[UIView animateWithDuration:0.3 animations:^ {
				buttonView.alpha = 0;
				if (useXmark) button.alpha = 0;
				else fromLabel.alpha = 0;

			}];
	transparantButton = true;

 }


%end

%hook SBMainSwitcherViewController
//hide the button when going back to the springboard in a smooth way
-(void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
	if (arg2 == false) {
			[UIView animateWithDuration:0.3 animations:^ {
				buttonView.alpha = 0;
				if (useXmark) button.alpha = 0;
				else fromLabel.alpha = 0;

			}];
		transparantButton = true;

	}
	%orig;

}

-(void)switcherContentController:(id)arg1 bringAppLayoutToFront:(id)arg2 {
	%orig;
	[UIView animateWithDuration:0.3 animations:^ {
		buttonView.alpha = 0;
		if (useXmark) button.alpha = 0;
		else fromLabel.alpha = 0;

	}];
	transparantButton = true;
}

%end

%end


void loadPrefs() {
	HBPreferences *file = [[HBPreferences alloc] initWithIdentifier:@"com.daveapps.quitallprefs"];
	enabled = [([file objectForKey:@"kEnabled"] ?: @(YES)) boolValue];
	darkStyle = [([file objectForKey:@"kDarkButton"] ?: @(NO)) boolValue];
	// leftButtonPlacement = [([file objectForKey:@"kLeftPlacement"] ?: @(NO)) boolValue];

	NSString *placement = [file objectForKey:@"kPlacement"];
	if ([placement isEqualToString:@"kLeftPlacement"]) {
		leftButtonPlacement = YES;
		centerButtonPlacement = NO;
	}
	else if ([placement isEqualToString:@"kCenterPlacement"]) {
		leftButtonPlacement = NO;
		centerButtonPlacement = YES;
	}
	else {
		leftButtonPlacement = NO;
		centerButtonPlacement = NO;
	}

	dontQuitNowPlaying = [([file objectForKey:@"kKeepMusicAlive"] ?: @(YES)) boolValue];
	dontQuitNavigation = [([file objectForKey:@"kKeepNavAlive"] ?: @(YES)) boolValue];
	useXmark = [([file objectForKey:@"useXmark"] ?: @(NO)) boolValue];

	if (enabled) {
        %init(tweak);
	}
}



%ctor {
	//load prefs
    loadPrefs();
	// loadFirstFont();
}
