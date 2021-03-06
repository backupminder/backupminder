//
//  AddPanelController.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#ifndef ADD_PANEL_CONTROLLER_H
#define ADD_PANEL_CONTROLLER_H

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "AddView.h"

@interface AddPanelController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate, NSTableViewDelegate>
{
    IBOutlet AddView *currentView;
	
	IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextField *sourceTextField;
	IBOutlet NSTextField *destinationTextField;
	IBOutlet NSTextField *filenameTextField;
	IBOutlet NSTextField *copiesTextField;
	IBOutlet NSTextField *daysTextField;
	
	IBOutlet NSTextField *summaryNameTextField;
	IBOutlet NSTextField *summarySourceTextField;
	IBOutlet NSTextField *summaryDestinationTextField;
	IBOutlet NSTextField *summaryFilenameTextField;
	IBOutlet NSTextField *summaryCopiesTextField;
	
	IBOutlet NSButton *nameViewNextButton;
	IBOutlet NSButton *sourceViewNextButton;
	IBOutlet NSButton *destinationViewNextButton;
	IBOutlet NSButton *filenameViewNextButton;
	IBOutlet NSButton *copiesViewNextButton;
	
	IBOutlet NSView *currentInstructionsView;
	IBOutlet NSTextField *instructionsText;
	
	IBOutlet NSButton *urlButton;
	IBOutlet NSButton *sourceFolderButton;
	IBOutlet NSButton *destinationFolderButton;
	
	IBOutlet NSTableView *filesListTable;
	NSMutableArray *filesList;
		
	CATransition *transition;
	
	NSMutableDictionary *editBackup;
	
	NSString *name;
	NSString *source;
	NSString *destination;
	NSString *filename;
	int copies;
	int days;
}

@property(retain) AddView *currentView;
@property(retain) NSView *currentInstructionsView;

@property(retain) NSTextField *instructionsText, *nameTextField, *sourceTextField, *destinationTextField, *filenameTextField, *copiesTextField, *daysTextField;
@property(retain) NSTextField *summaryNameTextField, *summarySourceTextField, *summaryDestinationTextField, *summaryFilenameTextField, *summaryCopiesTextField;
@property(retain) NSButton *urlButton, *sourceFolderButton, *destinationFolderButton, *nameViewNextButton, *sourceViewNextButton, *destinationViewNextButton, *filenameViewNextButton, *copiesViewNextButton;

@property(retain) NSTableView *filesListTable;

@property(retain) NSMutableDictionary *editBackup;

- (id) initWithBackup: (NSMutableDictionary*) backup;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)finish:(id)sender;

- (IBAction)selectBackupSource:(id)sender;
- (IBAction)selectArchiveDestination:(id)sender;

- (IBAction)openBackupMinderURL:(id)sender;

- (void)updateFileList;

- (void)showErrorDialog: (NSString *) errorText;
- (void)textDidChange:(NSNotification *)notification;

@end

#endif //ADD_PANEL_CONTROLLER_H
