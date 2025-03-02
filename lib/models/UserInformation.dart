/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the UserInformation type in your schema. */
class UserInformation extends amplify_core.Model {
  static const classType = const _UserInformationModelType();
  final String id;
  final String? _name;
  final int? _age;
  final String? _gender;
  final String? _occupation;
  final String? _education;
  final String? _medicalHistory;
  final amplify_core.TemporalDateTime? _updatedAt;
  final amplify_core.TemporalDateTime? _createdAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserInformationModelIdentifier get modelIdentifier {
      return UserInformationModelIdentifier(
        id: id
      );
  }
  
  String? get name {
    return _name;
  }
  
  int? get age {
    return _age;
  }
  
  String? get gender {
    return _gender;
  }
  
  String? get occupation {
    return _occupation;
  }
  
  String? get education {
    return _education;
  }
  
  String? get medicalHistory {
    return _medicalHistory;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  const UserInformation._internal({required this.id, name, age, gender, occupation, education, medicalHistory, updatedAt, createdAt}): _name = name, _age = age, _gender = gender, _occupation = occupation, _education = education, _medicalHistory = medicalHistory, _updatedAt = updatedAt, _createdAt = createdAt;
  
  factory UserInformation({String? id, String? name, int? age, String? gender, String? occupation, String? education, String? medicalHistory, amplify_core.TemporalDateTime? updatedAt, amplify_core.TemporalDateTime? createdAt}) {
    return UserInformation._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      age: age,
      gender: gender,
      occupation: occupation,
      education: education,
      medicalHistory: medicalHistory,
      updatedAt: updatedAt,
      createdAt: createdAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserInformation &&
      id == other.id &&
      _name == other._name &&
      _age == other._age &&
      _gender == other._gender &&
      _occupation == other._occupation &&
      _education == other._education &&
      _medicalHistory == other._medicalHistory &&
      _updatedAt == other._updatedAt &&
      _createdAt == other._createdAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("UserInformation {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("age=" + (_age != null ? _age!.toString() : "null") + ", ");
    buffer.write("gender=" + "$_gender" + ", ");
    buffer.write("occupation=" + "$_occupation" + ", ");
    buffer.write("education=" + "$_education" + ", ");
    buffer.write("medicalHistory=" + "$_medicalHistory" + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  UserInformation copyWith({String? name, int? age, String? gender, String? occupation, String? education, String? medicalHistory, amplify_core.TemporalDateTime? updatedAt, amplify_core.TemporalDateTime? createdAt}) {
    return UserInformation._internal(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt);
  }
  
  UserInformation copyWithModelFieldValues({
    ModelFieldValue<String?>? name,
    ModelFieldValue<int?>? age,
    ModelFieldValue<String?>? gender,
    ModelFieldValue<String?>? occupation,
    ModelFieldValue<String?>? education,
    ModelFieldValue<String?>? medicalHistory,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt
  }) {
    return UserInformation._internal(
      id: id,
      name: name == null ? this.name : name.value,
      age: age == null ? this.age : age.value,
      gender: gender == null ? this.gender : gender.value,
      occupation: occupation == null ? this.occupation : occupation.value,
      education: education == null ? this.education : education.value,
      medicalHistory: medicalHistory == null ? this.medicalHistory : medicalHistory.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value
    );
  }
  
  UserInformation.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _age = (json['age'] as num?)?.toInt(),
      _gender = json['gender'],
      _occupation = json['occupation'],
      _education = json['education'],
      _medicalHistory = json['medicalHistory'],
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'age': _age, 'gender': _gender, 'occupation': _occupation, 'education': _education, 'medicalHistory': _medicalHistory, 'updatedAt': _updatedAt?.format(), 'createdAt': _createdAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'age': _age,
    'gender': _gender,
    'occupation': _occupation,
    'education': _education,
    'medicalHistory': _medicalHistory,
    'updatedAt': _updatedAt,
    'createdAt': _createdAt
  };

  static final amplify_core.QueryModelIdentifier<UserInformationModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserInformationModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final AGE = amplify_core.QueryField(fieldName: "age");
  static final GENDER = amplify_core.QueryField(fieldName: "gender");
  static final OCCUPATION = amplify_core.QueryField(fieldName: "occupation");
  static final EDUCATION = amplify_core.QueryField(fieldName: "education");
  static final MEDICALHISTORY = amplify_core.QueryField(fieldName: "medicalHistory");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserInformation";
    modelSchemaDefinition.pluralName = "UserInformations";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["id"], name: null)
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.NAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.AGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.GENDER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.OCCUPATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.EDUCATION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.MEDICALHISTORY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserInformation.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UserInformationModelType extends amplify_core.ModelType<UserInformation> {
  const _UserInformationModelType();
  
  @override
  UserInformation fromJson(Map<String, dynamic> jsonData) {
    return UserInformation.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'UserInformation';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserInformation] in your schema.
 */
class UserInformationModelIdentifier implements amplify_core.ModelIdentifier<UserInformation> {
  final String id;

  /** Create an instance of UserInformationModelIdentifier using [id] the primary key. */
  const UserInformationModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UserInformationModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserInformationModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}