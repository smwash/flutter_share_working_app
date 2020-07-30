// createUser() async {
//   await _firestore.document('newUser').setData({
//     'username': 'Carol',
//     'postCount': 4,
//     'isAdmin': false,
//   });
// }

// updateUser() async {
//   await _firestore.document('newUser').updateData({
//     'username': 'Fayla',
//     'postCount': 4,
//     'isAdmin': false,
//   });
// }

// deleteUser() async {
//   await _firestore.document('newUser').delete();
// }

//get particular document.
// getUserData() async {
//   String id = 'W2PNF7eAseaABwEPw1RQ';
//   final document = await _firestore.document(id).get();
//   print(document.data);
//   print(document.documentID);
//   print(document.exists);
// }

//getting an entire collection
// getUsers() async {
//   final doc = await _firestore.limit(2).getDocuments();
//   doc.documents.forEach((document) {
//     print(document.data);
//     print(document.documentID);
//     print(document.exists);
//   });
// }
