import 'package:koin/instance_factory.dart';
import 'package:koin/koin.dart';
import 'package:koin/src/context/context_functions.dart';
import 'package:koin/src/context/context_handler.dart';
import 'package:test/test.dart';

import '../components.dart';
import '../extensions/koin_application_ext.dart';

import 'package:kt_dart/collection.dart';

void main() {
  test('can isolate several koin apps', () {
    var app1 = koinApplication((app) {
      app.module(module()..single((s) => ComponentA()));
    });

    var app2 = koinApplication((app) {
      app.module(module()..single((s) => ComponentA()));
    });

    var a1 = app1.koin.get<ComponentA>();
    var a2 = app2.koin.get<ComponentA>();

    expect(a1, isNot(a2));
  });

  test('can isolate several koin apps', () {
    var app = koinApplication((app) {
      app.module(module(createdAtStart: true)..single((s) => ComponentA()));
    });

    app.createEagerInstances();

    app.getBeanDefinition(ComponentA);

    final factoryInstance = app.koin.scopeRegistry.rootScope
            .getAllInstanceFactory()
            .first(
                (factory) => factory.beanDefinition.primaryType == ComponentA)
        as SingleInstanceFactory;

    expect(factoryInstance.created, true);
  });

  test('can isolate koin apps e standalone', () {
    startKoin((app) {
      app.module(module()..single((s) => ComponentA()));
    });

    var app2 = koinApplication((app) {
      app.module(module()..single((s) => ComponentA()));
    });

    var a1 = KoinContextHandler.get().get<ComponentA>();
    var a2 = app2.koin.get<ComponentA>();

    expect(a1, isNot(a2));
    stopKoin();
  });

  test('stopping koin releases resources', () {
    var module = Module()
      ..single<ComponentA>((s) => ComponentA())
      ..scope<Simple>((dsl) {
        dsl.scoped((s) => ComponentB(s.get()));
      });

    startKoin((app) {
      app.module(module);
    });

    var a1 = KoinContextHandler.get().get<ComponentA>();
    var scope1 = KoinContextHandler.get()
        .createScopeWithQualifier('simple', named<Simple>());
    var b1 = scope1.get<ComponentB>();

    stopKoin();

    startKoin((app) {
      app.module(module);
    });

    var a2 = KoinContextHandler.get().get<ComponentA>();
    var scope2 = KoinContextHandler.get()
        .createScopeWithQualifier('simple', named<Simple>());
    var b2 = scope2.get<ComponentB>();

    expect(a1, isNot(a2));
    expect(b1, isNot(b2));

    stopKoin();
  });

  test('create multiple context without named qualifier', () {
    var koinA = koinApplication((app) {
      app.modules([
        Module()..single((s) => ModelA()),
        Module()..single((s) => ModelB(s.get()))
      ]);
    });

    var koinB = koinApplication((app) {
      app.modules([
        Module()..single((s) => ModelC()),
      ]);
    });

    koinA.koin.get<ModelA>();
    koinA.koin.get<ModelB>();
    koinB.koin.get<ModelC>();

    try {
      koinB.koin.get<ModelA>();
      fail('');
    } catch (e) {}
    try {
      koinB.koin.get<ModelB>();
      fail('');
    } catch (e) {}
    try {
      koinA.koin.get<ModelC>();
      fail('');
    } catch (e) {}
  });
}

class ModelA {}

class ModelB {
  final ModelA a;

  ModelB(this.a);
}

class ModelC {}
