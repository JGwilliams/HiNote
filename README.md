HiNote
======
a simple to-do list for iPhone


Brief
Create an iPhone todo list application which is made up of many items. An item consists of a title,
description, date of create/update and whether it is complete or incomplete. The following functions
are expected:

✓- Add item to todo list.
✓- Edit item in todo list.
✓- Remove item from todo list.
✓- Mark item as completed or incomplete within the todo list.
✓- Persist data on the device.
✓- Sync and persist data to a remote service.


Preliminary Notes
This is a simple application, and due to time restraints probably best kept to a single view controller. To begin with, only the iPhone and most current operating system (iOS7) will be considered. The app will be structured to fit both 3.5" and 4" screens. Core Data will be utilised to persist data locally, while iCloud will be leveraged for the purposes of remote backup.

A simple UITableView will suffice to display the data since the most logical layout for an app of this nature on the tall, thin screen of the iPhone is a single column of data cells. On the iPad's larger, wider screen a UICollectionView would be a better fit and allow for more flexible development, but this is beyond the scope of the project for now. There is little benefit to allowing screen rotation, so the app will be locked to portrait orientations only.

For efficiency, it may be best to use an NSFetchedResultsController to govern the contents of the tableview. This means that we can concentrate on adding information to the database, and let the controller handle updating the table. This also gives the best expandability; were the app to expand to multiple view controllers and purposes, the table would be able to keep up-to-date with any changes to the database without need for further code.

In the interests of clarity, title shall be the largest, most obvious element. Date shall be small and unobtrusive to prevent distracting the user. Completion status will be displayed neatly on the right as a check box. If at all possible, accessibility elements should be added for the convenience of the partially-sighted. Elements should ideally be compatible with Text Kit, allowing the user to pick a font size that suits them.


Completion Status
At time of deadline, the majority of the requested features were functional. My only real concern was my choice of iCloud as the means of remote persistence. While this functions on a single device well enough, there seem to be issues with it persisting that information to other devices. This can either be very slow or, on the case of a fresh install, never happens. I suspect the problem to be somewhat to do with the user changing stores, but have not thus far been able to fully diagnose or fix it.

Sadly, detailed information about iCloud is quite difficult to come by and I probably chose the wrong time to learn the technology. Had I the time and resources to accomplish it, I would much rather have used a custom website and transferred the data with more ordinary services, whose operations were transparent and controllable, rather than iCloud which is more or less a black-box API.


Possible Future Expansions
- Option to split the table into complete and incomplete tasks
- An iPad variant, using a grid-based format.
- The ability to sort by different criteria.
- 'Completed on' date might be nice.
- Localisation for multiple language support
- Settings app option to turn on iCloud storage after initial launch. 
