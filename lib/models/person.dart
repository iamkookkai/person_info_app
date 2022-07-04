const String TABLE_PERSON = 'person';
const String COLUMN_ID = 'id';
const String COLUMN_NAME = 'name';
const String COLUMN_PHONE = 'phone';



class Person {
  int? id;
  String? name;
 
  String? phone;
  


 Person({
  this.id,
  this.name,
  this.phone,
 
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME: name,
      COLUMN_PHONE: phone,
      
    };

    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Person.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_ID];
    name = map[COLUMN_NAME];
    phone = map[COLUMN_PHONE];
   
  }

  @override
  String toString() => "$id, $name, $phone";
}
