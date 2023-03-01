import 'package:flutter/material.dart';
import 'package:notepad/sql_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String,dynamic>> _notes = [];
  bool _isLoading = true;

  void _refresahNotes()async{
    final data = await SqlHelper.getItems();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refresahNotes();
    print("......Number of Items ${_notes.length}");
  }

  final TextEditingController  _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem()async{
    await SqlHelper.createItem(_titleController.text, _descriptionController.text);
    _refresahNotes();
    print("......Number of Items ${_notes.length}");
  }
 Future<void> _updateItem(int id)async{
    await SqlHelper.updateItem(id, _titleController.text, _descriptionController.text);
    _refresahNotes();
 }
 void _deleteItem(int id)async{
    await SqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully Deleted a Note")));
    _refresahNotes();
 }
  void _showForm(int? id)async{
    if(id!=null){
      final existingNotes = _notes.firstWhere((element) => element['id'] == id);
      _titleController.text = existingNotes['title'];
      _descriptionController.text = existingNotes['description'];
    }

    showModalBottomSheet(context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=>Container(
          height: 600,
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom+120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: "Title"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: "Description"),
              ),

              ElevatedButton(onPressed: ()async{
                if(id == null){
                  await _addItem();
                }
                if(id != null){
                  await _updateItem(id);
                }
                _titleController.text = '';
                _descriptionController.text = '';
                Navigator.of(context).pop();
              }, child: Text(id == null? "Create New":"Update"))
            ],
          ),
        ));
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text("Notepad"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add,color: Colors.black,),
        onPressed: (){
          _showForm(null);
        },
      ),
    body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context,index)=>Card(
      color: Colors.green,
      margin: EdgeInsets.all(15),
      child: ListTile(
        title: Text(_notes[index]['title']),
        subtitle: Text(_notes[index]['description']),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(onPressed: (){
                _showForm(_notes[index]["id"]);
              }, icon: Icon(Icons.edit)),
              IconButton(onPressed: (){
                _deleteItem(_notes[index]['id']);
              }, icon: Icon(Icons.delete)),
            ],
          ),
        ),
      ),
    )),
    );
  }
}
