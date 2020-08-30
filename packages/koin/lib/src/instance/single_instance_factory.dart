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

import '../internal/exceptions.dart';

import '../definition/bean_definition.dart';
import '../koin_dart.dart';
import 'instance_context.dart';
import 'instance_factory.dart';

///
/// Single definition Instance holder
// @author Arnaud Giuliani
///
class SingleInstanceFactory<T> extends InstanceFactory<T> {
  SingleInstanceFactory(Koin koin, BeanDefinition<T> beanDefinition)
      : super(koin: koin, beanDefinition: beanDefinition);

  T _state;

  bool get created => _state != null;

  @override
  void dispose() {
    if (created) {
      beanDefinition?.onDispose?.runCallback(_state);
    }
    koin.loggerInstanceObserver?.onDispose(this);
    _state = null;
  }

  @override
  T createState(InstanceContext context) {
    if (_state != null) return _state;

    final created = super.createState(context);
    if (created == null) {
      throw IllegalStateException(
          "Single instance created couldn't return value");
    }
    return created;
  }

  @override
  T get(InstanceContext context) {
    if (!created) {
      _state = createState(context);
    }
    return _state;
  }
}