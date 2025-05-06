class RolesModel {
  int? roleID;
  String? role_name, role_description;

  RolesModel({this.roleID, this.role_name, this.role_description});

factory RolesModel.fromJeson(Map<String, dynamic> map){
  return RolesModel(roleID: map['roleID3'] as int?,
  role_name: map['role_name'] as String?,
  role_description: map['role_description'] as String?
  );
}

Map<String, dynamic> toMap(){
  return {
    'roleID': roleID,
    'role_name': role_name,
    'role_description': role_description
  };
}

}

RolesModel _roleModel = RolesModel();
