//
//  GItemsViewController.m
//  Test
//
//  Created by Deepak Rao on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GItemsViewController.h"


@implementation GItemsViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
	CGRect frame = self.view.frame;
	frame.origin.y = 0;
	frame.size.height = 416;
	self.view.frame = frame;
	
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"IN TABLE VIEW CELL FOR ROW");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.numberOfLines = 0;
	[cell.textLabel setFont:[UIFont systemFontOfSize:24.0f]];
	[cell.textLabel sizeToFit];
    
    // Configure the cell...
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Wow ... The food at the new Rays is amazing ... Cant wait to go there again";
	}
	else if(indexPath.row == 1){
		cell.textLabel.text = @"Checkout the new band at Coho's tonight.... It is also followed by a comedy night by some dumbshit comedian";
	}
	else {
		cell.textLabel.text = @"Nice Pic!!  DEEPAK_RAO_IS_A_MASTERS_STUDENT_AT_STANFORD_UNIVERSITY";
	}
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"IN TABLE VIEW HEIGHT FOR ROW %d ", indexPath.row);
	CGFloat width = 304;	

	NSString *text = nil;
	
	// Configure the cell...
	if (indexPath.row == 0) {
		text = @"Wow ... The food at the new Rays is amazing ... Cant wait to go there again";
	}
	else if(indexPath.row == 1){
		text = @"Checkout the new band at Coho's tonight.... It is also followed by a comedy night by some dumbshit comedian";
	}
	else {
		text = @"Nice Pic!!  DEEPAK_RAO_IS_A_MASTERS_STUDENT_AT_STANFORD_UNIVERSITY";
	}
	
	CGSize textSize = {width, 2000.0f };		// width and height of text area
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:24.0f] 
				   constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
	
	return MAX(size.height, 20);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

