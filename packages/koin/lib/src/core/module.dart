/*
 * Copyright 2017-2018 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:core';
import 'package:koin/src/core/scope_set.dart';
import 'definition/bean_definition.dart';
import 'definition/options.dart';
import 'qualifier.dart';

///
/// Koin Module
/// Gather/help compose Koin definitions
/// @author - Arnaud GIULIANI
///
/// Ported to Dart from Kotlin by:
/// @author - Pedro Bissonho
///
class Module {
  List<BeanDefinition> definitions = [];
  List<ScopeSet> scopes = [];
  final bool isCreatedAtStart;
  final bool override;

  Module([this.isCreatedAtStart, this.override]);

  ///
  /// Declare a [BeanDefinition] in current [Module]
  ///
  void declareDefinition<T>(BeanDefinition<T> definition, Options options) {
    definition.options = options;
    definitions.add(definition);
  }

  ///
  ///Declare a definition in current [Module]
  ///
  void declareScope(ScopeSet scope) {
    scopes.add(scope);
  }

  ///
  /// Declare a Single definition
  ///
  BeanDefinition<T> single<T>(
    Definition<T> definition, {
    Qualifier qualifier,
    bool createdAtStart = false,
    bool override = false,
  }) {
    var beanDefinition =
        BeanDefinition<T>.createSingle(qualifier, null, definition);
    declareDefinition(beanDefinition,
        Options(isCreatedAtStart: createdAtStart, override: override));

    return beanDefinition;
  }

  ///
  /// Declare a group a scoped definition with a given scope [Qualifier]
  ///
  ScopeSet scope(
      Qualifier scopeName, void Function(ScopeSet scope) scopeDeclaration) {
    var scopeX = ScopeSet(scopeName);

    scopeDeclaration(scopeX);
    declareScope(scopeX);
    return scopeX;
  }

  ScopeSet scopeSet(ScopeSet scopeSet) {
    declareScope(scopeSet);
    return scopeSet;
  }

  ScopeSet scopeOld(Qualifier scopeName) {
    var scopeX = ScopeSet(scopeName);
    declareScope(scopeX);
    return scopeX;
  }

  ///
  /// Declare a factory definition
  ///
  BeanDefinition<T> factory<T>(
    Definition<T> definition, {
    Qualifier qualifier,
    bool createdAtStart = false,
    bool override = false,
  }) {
    var beanDefinition =
        BeanDefinition<T>.createFactory(qualifier, null, definition);
    declareDefinition(beanDefinition,
        Options(isCreatedAtStart: createdAtStart, override: override));
    return beanDefinition;
  }
}

///
/// Define a Module
///
Module module({bool createdAtStart = false, bool override = false}) {
  var module = Module(createdAtStart, override);
  return module;
}
