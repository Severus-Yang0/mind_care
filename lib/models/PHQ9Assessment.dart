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


/** This is an auto generated class representing the PHQ9Assessment type in your schema. */
class PHQ9Assessment extends amplify_core.Model {
  static const classType = const _PHQ9AssessmentModelType();
  final String id;
  final String? _userId;
  final amplify_core.TemporalDateTime? _date;
  final int? _q1;
  final int? _q2;
  final int? _q3;
  final int? _q4;
  final int? _q5;
  final int? _q6;
  final int? _q7;
  final int? _q8;
  final int? _q9;
  final int? _totalScore;
  final String? _severity;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PHQ9AssessmentModelIdentifier get modelIdentifier {
      return PHQ9AssessmentModelIdentifier(
        id: id
      );
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get date {
    try {
      return _date!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q1 {
    try {
      return _q1!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q2 {
    try {
      return _q2!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q3 {
    try {
      return _q3!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q4 {
    try {
      return _q4!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q5 {
    try {
      return _q5!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q6 {
    try {
      return _q6!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q7 {
    try {
      return _q7!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q8 {
    try {
      return _q8!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get q9 {
    try {
      return _q9!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get totalScore {
    try {
      return _totalScore!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get severity {
    try {
      return _severity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const PHQ9Assessment._internal({required this.id, required userId, required date, required q1, required q2, required q3, required q4, required q5, required q6, required q7, required q8, required q9, required totalScore, required severity, createdAt, updatedAt}): _userId = userId, _date = date, _q1 = q1, _q2 = q2, _q3 = q3, _q4 = q4, _q5 = q5, _q6 = q6, _q7 = q7, _q8 = q8, _q9 = q9, _totalScore = totalScore, _severity = severity, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory PHQ9Assessment({String? id, required String userId, required amplify_core.TemporalDateTime date, required int q1, required int q2, required int q3, required int q4, required int q5, required int q6, required int q7, required int q8, required int q9, required int totalScore, required String severity, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return PHQ9Assessment._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      date: date,
      q1: q1,
      q2: q2,
      q3: q3,
      q4: q4,
      q5: q5,
      q6: q6,
      q7: q7,
      q8: q8,
      q9: q9,
      totalScore: totalScore,
      severity: severity,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PHQ9Assessment &&
      id == other.id &&
      _userId == other._userId &&
      _date == other._date &&
      _q1 == other._q1 &&
      _q2 == other._q2 &&
      _q3 == other._q3 &&
      _q4 == other._q4 &&
      _q5 == other._q5 &&
      _q6 == other._q6 &&
      _q7 == other._q7 &&
      _q8 == other._q8 &&
      _q9 == other._q9 &&
      _totalScore == other._totalScore &&
      _severity == other._severity &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PHQ9Assessment {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("date=" + (_date != null ? _date!.format() : "null") + ", ");
    buffer.write("q1=" + (_q1 != null ? _q1!.toString() : "null") + ", ");
    buffer.write("q2=" + (_q2 != null ? _q2!.toString() : "null") + ", ");
    buffer.write("q3=" + (_q3 != null ? _q3!.toString() : "null") + ", ");
    buffer.write("q4=" + (_q4 != null ? _q4!.toString() : "null") + ", ");
    buffer.write("q5=" + (_q5 != null ? _q5!.toString() : "null") + ", ");
    buffer.write("q6=" + (_q6 != null ? _q6!.toString() : "null") + ", ");
    buffer.write("q7=" + (_q7 != null ? _q7!.toString() : "null") + ", ");
    buffer.write("q8=" + (_q8 != null ? _q8!.toString() : "null") + ", ");
    buffer.write("q9=" + (_q9 != null ? _q9!.toString() : "null") + ", ");
    buffer.write("totalScore=" + (_totalScore != null ? _totalScore!.toString() : "null") + ", ");
    buffer.write("severity=" + "$_severity" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PHQ9Assessment copyWith({String? userId, amplify_core.TemporalDateTime? date, int? q1, int? q2, int? q3, int? q4, int? q5, int? q6, int? q7, int? q8, int? q9, int? totalScore, String? severity, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return PHQ9Assessment._internal(
      id: id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      q1: q1 ?? this.q1,
      q2: q2 ?? this.q2,
      q3: q3 ?? this.q3,
      q4: q4 ?? this.q4,
      q5: q5 ?? this.q5,
      q6: q6 ?? this.q6,
      q7: q7 ?? this.q7,
      q8: q8 ?? this.q8,
      q9: q9 ?? this.q9,
      totalScore: totalScore ?? this.totalScore,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  PHQ9Assessment copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<amplify_core.TemporalDateTime>? date,
    ModelFieldValue<int>? q1,
    ModelFieldValue<int>? q2,
    ModelFieldValue<int>? q3,
    ModelFieldValue<int>? q4,
    ModelFieldValue<int>? q5,
    ModelFieldValue<int>? q6,
    ModelFieldValue<int>? q7,
    ModelFieldValue<int>? q8,
    ModelFieldValue<int>? q9,
    ModelFieldValue<int>? totalScore,
    ModelFieldValue<String>? severity,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? updatedAt
  }) {
    return PHQ9Assessment._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      date: date == null ? this.date : date.value,
      q1: q1 == null ? this.q1 : q1.value,
      q2: q2 == null ? this.q2 : q2.value,
      q3: q3 == null ? this.q3 : q3.value,
      q4: q4 == null ? this.q4 : q4.value,
      q5: q5 == null ? this.q5 : q5.value,
      q6: q6 == null ? this.q6 : q6.value,
      q7: q7 == null ? this.q7 : q7.value,
      q8: q8 == null ? this.q8 : q8.value,
      q9: q9 == null ? this.q9 : q9.value,
      totalScore: totalScore == null ? this.totalScore : totalScore.value,
      severity: severity == null ? this.severity : severity.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  PHQ9Assessment.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _date = json['date'] != null ? amplify_core.TemporalDateTime.fromString(json['date']) : null,
      _q1 = (json['q1'] as num?)?.toInt(),
      _q2 = (json['q2'] as num?)?.toInt(),
      _q3 = (json['q3'] as num?)?.toInt(),
      _q4 = (json['q4'] as num?)?.toInt(),
      _q5 = (json['q5'] as num?)?.toInt(),
      _q6 = (json['q6'] as num?)?.toInt(),
      _q7 = (json['q7'] as num?)?.toInt(),
      _q8 = (json['q8'] as num?)?.toInt(),
      _q9 = (json['q9'] as num?)?.toInt(),
      _totalScore = (json['totalScore'] as num?)?.toInt(),
      _severity = json['severity'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'date': _date?.format(), 'q1': _q1, 'q2': _q2, 'q3': _q3, 'q4': _q4, 'q5': _q5, 'q6': _q6, 'q7': _q7, 'q8': _q8, 'q9': _q9, 'totalScore': _totalScore, 'severity': _severity, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'date': _date,
    'q1': _q1,
    'q2': _q2,
    'q3': _q3,
    'q4': _q4,
    'q5': _q5,
    'q6': _q6,
    'q7': _q7,
    'q8': _q8,
    'q9': _q9,
    'totalScore': _totalScore,
    'severity': _severity,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PHQ9AssessmentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PHQ9AssessmentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final DATE = amplify_core.QueryField(fieldName: "date");
  static final Q1 = amplify_core.QueryField(fieldName: "q1");
  static final Q2 = amplify_core.QueryField(fieldName: "q2");
  static final Q3 = amplify_core.QueryField(fieldName: "q3");
  static final Q4 = amplify_core.QueryField(fieldName: "q4");
  static final Q5 = amplify_core.QueryField(fieldName: "q5");
  static final Q6 = amplify_core.QueryField(fieldName: "q6");
  static final Q7 = amplify_core.QueryField(fieldName: "q7");
  static final Q8 = amplify_core.QueryField(fieldName: "q8");
  static final Q9 = amplify_core.QueryField(fieldName: "q9");
  static final TOTALSCORE = amplify_core.QueryField(fieldName: "totalScore");
  static final SEVERITY = amplify_core.QueryField(fieldName: "severity");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PHQ9Assessment";
    modelSchemaDefinition.pluralName = "PHQ9Assessments";
    
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
      key: PHQ9Assessment.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.DATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q1,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q2,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q3,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q4,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q5,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q6,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q7,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q8,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.Q9,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.TOTALSCORE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.SEVERITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PHQ9Assessment.UPDATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _PHQ9AssessmentModelType extends amplify_core.ModelType<PHQ9Assessment> {
  const _PHQ9AssessmentModelType();
  
  @override
  PHQ9Assessment fromJson(Map<String, dynamic> jsonData) {
    return PHQ9Assessment.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'PHQ9Assessment';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [PHQ9Assessment] in your schema.
 */
class PHQ9AssessmentModelIdentifier implements amplify_core.ModelIdentifier<PHQ9Assessment> {
  final String id;

  /** Create an instance of PHQ9AssessmentModelIdentifier using [id] the primary key. */
  const PHQ9AssessmentModelIdentifier({
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
  String toString() => 'PHQ9AssessmentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PHQ9AssessmentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}