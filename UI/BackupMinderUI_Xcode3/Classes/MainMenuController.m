//
//  MainMenuController.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/8/12.
//

#import "MainMenuController.h"
#import "Definitions.h"
#import "BackupManager.h"
#import "FileUtilities.h"

@implementation MainMenuController


- (void)mainViewDidLoad;
{
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if (self)
    {                
        // Initialize the error alert
        m_errorAlert = [[NSAlert alloc] init];
        NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
                              pathForResource:@"BackupMinder" ofType:@"icns"];
        NSImage *image = [[[NSImage alloc] initWithContentsOfFile:iconPath]
                            autorelease];
        [m_errorAlert setIcon:image];
        [m_errorAlert addButtonWithTitle:@"OK"];
        [m_errorAlert setMessageText:@"Error"];
        [m_errorAlert setAlertStyle:NSCriticalAlertStyle];
        NSArray *buttons = [m_errorAlert buttons];
        NSButton *okButton = [buttons objectAtIndex:0];
        [okButton setKeyEquivalent:@""];
        [okButton setKeyEquivalent:@"\r"];
        
        // Initialize the "Are you sure?" alert
        m_removeAlert = [[NSAlert alloc] init];
        // Icon is the same
        [m_removeAlert setIcon:[[[NSImage alloc] 
                                 initWithContentsOfFile:iconPath] autorelease]];
        [m_removeAlert addButtonWithTitle:@"Yes"];
        [m_removeAlert addButtonWithTitle:@"Cancel"];
        [m_removeAlert setMessageText:@"Are you sure?"];
        [m_removeAlert setAlertStyle:NSCriticalAlertStyle];
        [m_removeAlert setInformativeText:@"This will remove the BackupSet "
         "configuration, no data files will be removed.  Confirm Deletion?"];
        buttons = [m_removeAlert buttons];
        NSButton *uninstallButton = [buttons objectAtIndex:0];
        NSButton *cancelButton = [buttons objectAtIndex:1];
        [uninstallButton setKeyEquivalent:@""];
        [cancelButton setKeyEquivalent:@"\r"];
        
        [m_addButton setToolTip:@"Create a New BackupSet"];
        [m_removeButton setToolTip:@"Remove the Selected BackupSet"];
        [m_editButton setToolTip:@"Edit the Selected BackupSet"];
		[runButton setToolTip:@"Force run of the Selected BackupSet"];
    }
    
    return self;
}

- (void)dealloc
{
    [m_errorAlert release];
    [m_removeAlert release];
    
    [super dealloc];   
}

- (void)setAuthorized:(BOOL)authorized_
{
    [m_addButton setEnabled:authorized_];
    [m_editButton setEnabled:authorized_];
    [m_removeButton setEnabled:authorized_];
	[runButton setEnabled:authorized_];
    [m_refreshButton setEnabled:authorized_];
    [m_backupsTableView setEnabled:authorized_];
    
	currentlyAuthorized=authorized_;
    //Unselect the row to disable remove/edit buttons
    //[m_backupsTableView deselectAll:nil];
	[m_backupsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection: NO];

}

- (void)orderFrontStandardAboutPanel:(id)sender_
{
	NSLog (@"FCK YOU");
}

#pragma mark -
#pragma mark Button methods

- (IBAction)addBackupObject:(id)sender_
{
	addPanel = [[AddPanelController alloc] init];

    [NSApp beginSheet:[addPanel window] 
	   modalForWindow:[self window]
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:addPanel];
    
    [m_backupsTableView reloadData];
	[m_backupsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection: NO];
	
}

- (IBAction)removeBackupObject:(id)sender_
{
	[m_removeAlert beginSheetModalForWindow:[self window] modalDelegate:self 
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                contextInfo:nil];    
}

- (IBAction)editBackupObject:(id)sender_
{
    NSMutableDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                  [m_backupsTableView selectedRow]];
    	
    if (backupObject == nil)
        return;
    
	editPanel=[[AddPanelController alloc] initWithBackup:backupObject];
	
    [NSApp beginSheet:[editPanel window]
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:editPanel];
    
}

- (IBAction)refresh:(id)sender_
{
    [BackupManager initializeBackups];
    [m_backupsTableView reloadData];
	[m_backupsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection: NO];
}

- (IBAction)showHelp:(id)sender
{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.watchmanmonitoring.com/backupminder"]];
}

- (void)clearSelection
{
	[m_backupsTableView reloadData];
	
    // Unselect the row so that the user must click
    // on a row again to update the information
    // Otherwise the information displayed might be stale
    [m_backupsTableView deselectAll:nil];
	[m_backupsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection: NO];
}

- (IBAction)runBackup: (id)sender
{
	
	NSLog(@"Here: %@", [[BackupManager backupObjectAtIndex: [m_backupsTableView selectedRow]] objectForKey:kWatchPath]);
	if ([[NSFileManager defaultManager] createFileAtPath:[[[[BackupManager backupObjectAtIndex: [m_backupsTableView selectedRow]] objectForKey:kWatchPath] objectAtIndex:0] stringByAppendingPathComponent:@".runbackupminder"]
													contents:[@"Temp file to force run of BackupMinder. This can be deleted." dataUsingEncoding:NSUTF8StringEncoding]
													attributes:nil])
		NSLog(@"Created");
	else 
		NSLog(@"Can't do it!");

}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView_;
{
	return [[BackupManager backups] count];
}

- (id)tableView:(NSTableView *)tableView_ objectValueForTableColumn:
(NSTableColumn *)tableColumn_ row:(NSInteger)row_;
{
    if (tableColumn_ == nil)
    {
        return nil;
    }
    
    NSMutableDictionary *backup = [[BackupManager backups] objectAtIndex:row_];
    if (backup == nil)
    {
        return nil;
    }
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
    {
        return [NSNumber numberWithBool:
                ! [[backup objectForKey:kDisabled] boolValue]];
    }
    else
    {
        return [[backup objectForKey: kLabel] substringFromIndex: 
                [kLaunchDaemonPrefix length]];
    }
}

- (void)tableView:(NSTableView *)tableView_ setObjectValue:(id)object_ 
   forTableColumn:(NSTableColumn *)tableColumn_ row:(NSInteger)row_
{
    if (tableColumn_ == nil)
    {
        return;
    }
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
    {
        //Get Dictionary
		NSMutableDictionary *backup = 
            [[BackupManager backups] objectAtIndex:row_];
        
		if (backup == nil)
		{
#ifdef DEBUG
            NSLog (@"AppDelegate::setObjectValue: BackupSet object is nil");
#endif //DEBUG
            [m_errorAlert setInformativeText:@"Cannot modify the BackupSet."];
            [m_errorAlert runModal];
            
			return;
		}
        
        [backup setObject:[NSNumber numberWithBool:! [object_ boolValue]] 
                   forKey:kDisabled];
        
        if (! [BackupManager editBackupObject:backup withObject:backup])
        {
            [m_errorAlert setMessageText:@"Error"];
            [m_errorAlert setInformativeText:[BackupManager lastError]];
            [m_errorAlert runModal];
        }
        
        [m_backupsTableView reloadData];
    }    
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification_;
{
    NSInteger index = [m_backupsTableView selectedRow];
    
    // If nothing is selected, disable the Edit and Remove buttons,
    // clear the text fields, and bail
    if (index < 0)
    {
        [m_removeButton setEnabled:NO];
        [m_editButton setEnabled:NO];
		[runButton setEnabled:NO];
        
        [m_nameTextField setStringValue:@""];
        [m_backupSourceTextField setStringValue:@""];
        [m_archiveDestinationTextField setStringValue:@""];
        [m_nameContainsTextField setStringValue:@""];
        [m_backupsToLeaveTextField setStringValue:@""];
        [m_warnDaysTextField setStringValue:@""];
        return;
    }
    
    // Otherwise, enable the Edit and Remove buttons
    [m_removeButton setEnabled:currentlyAuthorized];
    [m_editButton setEnabled:currentlyAuthorized];
	[runButton setEnabled:currentlyAuthorized];
    
    // Get the associated backup object
    NSMutableDictionary *backupObject = 
        [BackupManager backupObjectAtIndex:index];
    
    if (backupObject == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::tableViewSelectionDidChange: object is nil");
#endif //DEBUG
        [m_errorAlert setInformativeText:@"There does not appear to be a "
         "BackupSet associated with your selection"];
        [m_errorAlert runModal];
        return;
    }    
    
    [m_nameTextField setStringValue:[[backupObject objectForKey: kLabel]
                                     substringFromIndex: 
                                        [kLaunchDaemonPrefix length]]];
    
    NSArray *arguments = [backupObject objectForKey:kProgramArguments];
    
    if (arguments == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::tableViewSelectionDidChange: arguments is nil");
#endif //DEBUG
        [m_errorAlert setInformativeText:@"The BackupSet does not appear to"
         " contain the proper arguments"];
        [m_errorAlert runModal];
        return;
    }
    
    // Iterate through the arguements
    // When I match a key, the next argument should be the value
    // But check out-of-bounds just in case
    for (int i = 0; i < [arguments count]; ++i)
    {
        if ([[arguments objectAtIndex:i] isEqual:kBackupSource])
        {
            if (i + 1 < [arguments count])
            {                
                NSString *folder = [arguments objectAtIndex: i + 1];
                // Only need the folder to display
                [m_backupSourceTextField setStringValue:
                 [folder lastPathComponent]];
                
                // Set the tooltip as the full path
                [m_backupSourceTextField setToolTip:folder];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kArchiveDestination])
        {
            if (i + 1 < [arguments count])
            {
                NSString *folder = [arguments objectAtIndex: i + 1];
                // Only need the folder to display
                [m_archiveDestinationTextField setStringValue:
                 [folder lastPathComponent]];
                
                // Set the tooltip as the full path
                [m_archiveDestinationTextField setToolTip:folder];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kNameContains])
        {
            if (i + 1 < [arguments count])
            {
                [m_nameContainsTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kBackupsToLeave])
        {
            if (i + 1 < [arguments count])
            {
                [m_backupsToLeaveTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kWarnDays])
        {
            if (i + 1 < [arguments count])
            {
                [m_warnDaysTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
    }
}

- (NSCell *)tableView:(NSTableView *)tableView_ 
    dataCellForTableColumn:(NSTableColumn *)tableColumn_ row:(NSInteger)row_
{
    if (tableColumn_ == nil)
    {
        return nil;
    }
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
	{
        NSButtonCell *cell = [[NSButtonCell new] autorelease];
        [cell setTitle:@""];
        [cell setButtonType:NSSwitchButton];
        [cell setImagePosition:NSImageOverlaps];
        [cell setImageScaling:NSImageScaleProportionallyDown];
        [cell setTarget:self];
        return cell;
    }
    
    return [[NSTextFieldCell new] autorelease];
}

#pragma mark -
#pragma mark NSAlert Delegate Methods

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo;
{
    // The "Are you sure?" alert
    if (alert == m_removeAlert && returnCode == NSAlertFirstButtonReturn)
	{
        NSMutableDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                      [m_backupsTableView selectedRow]];
        
        if (backupObject == nil)
        {
#ifdef DEBUG
            NSLog (@"AppDelegate::removeBackupObject: Cannot remove nil object");
#endif //DEBUG   
            return;
        }
        
        if (! [BackupManager removeBackupObject:backupObject])
        {
#ifdef DEBUG
            NSLog (@"AppDelegate::removeBackupObject: Error deleting object");
#endif //DEBUG
            [m_errorAlert setInformativeText:[BackupManager lastError]];
            [m_errorAlert runModal];
            return;
        }
        
		[self clearSelection];
    }
}

#pragma mark -
#pragma mark Sheet Delegate Methods

- (void)sheetDidEnd:(NSWindow *)sheet_ returnCode:(NSInteger)returnCode_
        contextInfo:(void *)contextInfo_
{
	[self clearSelection];
	
	[(id) contextInfo_ release];
	
	[self refresh:self];
}

@end
