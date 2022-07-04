import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:person_info_app/models/person.dart';
import 'package:person_info_app/provider/db_provider.dart';

class PersonList extends StatefulWidget {
  const PersonList({Key? key}) : super(key: key);

  @override
  State<PersonList> createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  var _refresh = GlobalKey<RefreshIndicatorState>();

  late DBProvider dbProvider;

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }

  @override
  void dispose() {
    dbProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
  


   floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(20.0),
        ),
        child: FloatingActionButton.extended(
         // backgroundColor: Color(0xFF2980b9),
          onPressed: (){
            createDialog();
          },
          elevation: 0,
          label: Row(
           // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.person_add),
              SizedBox(width: 10,),
              Text(
                "Add New Person",
                style: TextStyle(
                  fontSize: 18.0
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    
   
   
    );
  }

  _buildAppBar() => AppBar(
        title: Text("Person Info"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _refresh.currentState!.show();
              dbProvider.deleteAll();
            },
          )
        ],
      );

  _buildContent() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 2));
        setState(() {});
      },
      child: FutureBuilder(
        future: dbProvider.getPersons(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Person> persons = snapshot.data as List<Person>;
            if (persons.length > 0) {
             
              return _buildListView(persons.reversed.toList());
            }
            return Center(
              child: Text("NO DATA"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _buildListView(List<Person> person) {
    return ListView.builder(
      itemCount: person.length,
      itemBuilder: (context, index) => Card(
        elevation: 6,
        //margin: EdgeInsets.all(2),
        child: ListTile(
          onTap: () {
             detailDialog(person[index]);
            
          },
          leading: CircleAvatar(
            child:
                Icon(Icons.person), 
          ),
          title: Text(person[index].name.toString()),
          subtitle: Text(person[index].phone.toString()),
          trailing: Wrap(
             spacing: 12,
           children: [
             IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      editDialog(person[index]);
                    },
                  ),
                 
             IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                       _refresh.currentState!.show();
                      dbProvider.deletePerson(person[index].id!);
                      await Future.delayed(Duration(seconds: 2));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Person deleted"),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () {
                              _refresh.currentState!.show();
                              dbProvider.insertPerson(person[index]).then((value) {
                                print(person);
                              });
                            },
                          ),
                        ),
                      ); 
                    },
                  )
           ],
         ),
         ),
      ),
    );
  }

  _buildBody() => FutureBuilder(
        future: dbProvider.initDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildContent();
          }

          return Center(
            child: snapshot.hasError
                ? Text(snapshot.error.toString())
                : CircularProgressIndicator(),
          );
        },
      );

  createDialog() {
    var _formKey = GlobalKey<FormState>();
    Person person = Person();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                   validator: (value) {
                        if (value!.isEmpty) {
                          return 'Name is Required';
                        }
                       
                        return null;
                      },

                  decoration: InputDecoration(hintText: "Name"),
                  onSaved: (value) {
                    person.name = value;
                  },
                ),
                TextFormField(
                  maxLength: 10,
                   keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                   validator: (value) {
                        if (value!.isEmpty) {
                          return 'Phone is Required';
                        }
                        if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                            .hasMatch(value)) {
                          return 'Phone Number Invalid';
                        }
                      },
                  decoration: InputDecoration(hintText: "phone"),
                  onSaved: (value) {
                    person.phone = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.insertPerson(person).then((value) {
                          print(person);
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  editDialog(Person person) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: person.name,
                  decoration: InputDecoration(hintText: "Name"),
                  onSaved: (value) {
                    person.name = value;
                  },
                ),
                TextFormField(
                  initialValue: person.phone.toString(),
                  decoration: InputDecoration(hintText: "Phone"),
                  onSaved: (value) {
                    person.phone = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Update"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _refresh.currentState!.show();
                        Navigator.pop(context);
                        dbProvider.updatePerson(person).then((row) {
                          print(row.toString());
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

detailDialog(Person person) {
    var _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                 CircleAvatar(
            child:
                Icon(Icons.person), 
          ),
          //SizedBox(height: 10,),
               
                TextFormField(
                  enabled: false,
                  initialValue: person.name,
                  decoration: InputDecoration(hintText: "Name"),
                  onSaved: (value) {
                    person.name = value;
                  },
                ),
                TextFormField(
                  enabled: false,
                  initialValue: person.phone.toString(),
                  decoration: InputDecoration(hintText: "Phone"),
                  onSaved: (value) {
                    person.phone = value;
                  },
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    child: Text("Close"),
                    onPressed: () {
                     

                        Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


}
