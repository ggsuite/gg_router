// @license
// Copyright (c) 2019 - 2021 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gg_router/gg_router.dart';
import 'package:gg_router/src/gg_route_tree_node.dart';

class OtherClass {}

void main() {
  late GgRouteTreeNode root;
  late GgRouteTreeNode childA0;
  late GgRouteTreeNode childA1;
  late GgRouteTreeNode childA2;
  late GgRouteTreeNode childA2Index;
  late GgRouteTreeNode childB;
  late GgRouteTreeNode childC;

  init() {
    root = GgRouteTreeNode.newRoot();
    childA0 = exampleRouteNode(name: 'child-a0', parent: root);
    childA1 = exampleRouteNode(name: 'child-a1', parent: root);
    childA2 = exampleRouteNode(name: 'child-a2', parent: root);
    childA2Index = exampleRouteNode(name: '_INDEX_', parent: childA2);
    childB = exampleRouteNode(name: 'child-b', parent: childA0);
    childC = exampleRouteNode(name: 'child-c', parent: childB);
  }

  dispose() {
    root.dispose();
    expect(root.isDisposed, isTrue);
  }

  group('Param', () {
    // #########################################################################
    group('constructor', () {
      test('should create a parameter', () {
        init();
        dispose();
      });
    });
  });

  group('GgRouteTreeNode', () {
    // #########################################################################
    group('dispose()', () {
      test('should remove all children from the node. '
          'Should remove the node from its parents list of children. '
          'Should reset the staged child property of its parent. '
          'Should dispose also all children', () {
        init();
        final parent = childB.parent!;
        childB.navigateTo('.');

        // At the beginning none of the nodes is disposed
        expect(root.isDisposed, false);
        expect(childA0.isDisposed, false);
        expect(childB.isDisposed, false);
        expect(childC.isDisposed, false);

        // Stage childB
        expect(childB.isStaged, true);
        expect(childB.children.length, 1);
        expect(parent.children.length, 1);
        expect(parent.stagedChild, childB);

        // Dispose childB
        // => childA0 should not have any children anymore
        // => childB should not have any children anymore
        // => childA0 should not have a staged child anymore
        // => childC as well childB should be disposed
        childB.dispose();
        expect(parent.children.length, 0);
        expect(childB.children.length, 0);
        expect(parent.stagedChild, null);
        expect(childC.isDisposed, true);
        expect(childB.isDisposed, true);
        expect(childA0.isDisposed, false);
        expect(root.isDisposed, false);

        // Finalize
        dispose();
      });

      test('should make sure no changes are delivered anymore', () {
        fakeAsync((fake) {
          init();

          // Listen to changes
          var changeCounter = 0;
          root.onChange.listen((event) => changeCounter++);

          var changeCounter1 = 0;
          childC.onChange.listen((event) => changeCounter1++);

          // Make a test change before dispose
          // => Changes are delivered
          childC.findOrCreateChild('newChild1');
          fake.flushMicrotasks();
          expect(changeCounter, 1);
          expect(changeCounter1, 1);

          // Make a change and dispose then
          // => Changes are not delivered anymore
          childC.findOrCreateChild('newChild2');
          root.dispose();
          childC.dispose();
          fake.flushMicrotasks();
          expect(changeCounter, 1);
          expect(changeCounter1, 1);
        });
      });
    });

    // #########################################################################
    group('name, isValidName', () {
      test('should return the name of the node', () {
        init();
        expect(root.name, '_ROOT_');
        expect(childA0.name, 'child-a0');
        expect(childB.name, 'child-b');
        expect(childC.name, 'child-c');
        dispose();
      });

      test(
        'should throw an exception if name of an root node is not "_ROOT_"',
        () {
          init();
          expect(
            () => GgRouteTreeNode(name: 'root', parent: null),
            throwsA(
              predicate((GgRouteTreeNodeError error) {
                expect(error.id, 'GRC008501');
                expect(error.message, 'Root nodes must have name "_ROOT_".');
                return true;
              }),
            ),
          );
        },
      );

      test('should throw an exception if name contains invalid chars', () {
        init();
        expect(
          () => GgRouteTreeNode(name: 'root#3%', parent: root),
          throwsA(
            predicate((GgRouteTreeNodeError error) {
              expect(error.id, 'GRC008502');
              expect(
                error.message,
                'The name "root#3%" is not a valid node name. Node names must only contain letters, numbers, underscore or minus.',
              );
              return true;
            }),
          ),
        );
      });

      test(
        'should throw an exception if name is "_ROOT_" and a parent is given',
        () {
          init();
          expect(
            () => GgRouteTreeNode(name: '_ROOT_', parent: root),
            throwsA(
              predicate((GgRouteTreeNodeError error) {
                expect(error.id, 'GRC008503');
                expect(
                  error.message,
                  'Nodes with name "_ROOT_" are root nodes and must not have a parent.',
                );
                return true;
              }),
            ),
          );
        },
      );

      test('should allow wildcard "*"', () {
        expect(GgRouteTreeNode.isValidName('*'), isTrue);
      });
    });

    // #########################################################################
    group('toString', () {
      test('should return the path of the node', () {
        init();
        expect(childC.toString(), childC.path);
      });
    });

    // #########################################################################
    group('parent', () {
      test('should return null for root and parent for child nodes', () {
        init();
        expect(root.parent, null);
        expect(childA0.parent, root);
        expect(childB.parent, childA0);
        expect(childC.parent, childB);
      });
    });

    // #########################################################################
    group('root', () {
      test('should return the root node in the hierachy', () {
        init();
        expect(root.root, root);
        expect(childA0.root, root);
        expect(childB.root, root);
        expect(childC.root, root);
      });
    });

    // #########################################################################
    group('isRoot', () {
      test('returns true if node is root node, otherwise false', () {
        init();
        expect(root.isRoot, true);
        expect(childC.isRoot, false);
      });
    });

    // #########################################################################
    group('widgetIndex', () {
      test(
        'returns null by default and needs to be initialized by GgRouter',
        () {
          init();
          expect(root.widgetIndex, null);
          childA0.widgetIndex = 1;
          expect(childA0.widgetIndex, 1);
        },
      );
    });

    // #########################################################################
    group('onChange', () {
      test(
        'should inform if any parameter in the subtree changes or any node is added, removed or staged',
        () {
          fakeAsync((fake) {
            init();

            // ..................
            // Listen to onChange
            int counter = 0;
            final s = root.onChange.listen((event) => counter++);
            checkCounter([int? expected]) {
              fake.flushMicrotasks();
              expect(counter, expected ?? 1);
              counter = 0;
            }

            // ...............
            // Add a parameter
            final param = childC.findOrCreateParam(name: 'a', seed: 10);
            checkCounter();

            // Change a parameter
            param.value = 11;
            checkCounter();

            // ...........
            // Add a child
            final childD = childC.findOrCreateChild('child-d');
            checkCounter();

            // Remove a child
            childC.removeChild(childD);
            checkCounter();

            // ...........
            // Stage a child
            childC.navigateTo('.');
            checkCounter(2);

            childA1.navigateTo('.');
            checkCounter(2);

            // ........
            // Finalize
            s.cancel();
          });
        },
      );
    });

    // #########################################################################
    group('isStaged', () {
      test('should be false by default', () {
        init();
        expect(root.isStaged, false);
        expect(childA0.isStaged, false);
        expect(childB.isStaged, false);
        expect(childC.isStaged, false);
      });

      test(
        'If isStaged set to true, also all parent nodes should become staged',
        () {
          init();
          childB.navigateTo('.');
          expect(childB.isStaged, true);
          expect(root.isStaged, true);
          expect(childB.isStaged, true);
          expect(childC.isStaged, false);
        },
      );

      test(
        'If isStaged set to true, the existing staged child becomes unstaged',
        () {
          init();

          // Initally childA0 is staged
          childA0.navigateTo('.');
          expect(childA0.isStaged, true);
          expect(root.isStaged, true);
          expect(childA0.isStaged, true);

          // Now we set childA1 to staged
          childA1.navigateTo('.');
          expect(childA1.isStaged, true);

          // childA0 should not be staged anymore
          expect(childA0.isStaged, false);
          expect(childA1.isStaged, true);
        },
      );

      test(
        'If isStaged is set to false, all child remain staged as before',
        () {
          init();

          // Currently the complete path is staged
          childC.navigateTo('.');
          expect(root.isStaged, true);
          expect(childA0.isStaged, true);
          expect(childB.isStaged, true);
          expect(childC.isStaged, true);

          // Now we set childA to unstaged
          childA1.navigateTo('.');
          expect(childA1.isStaged, true);

          // The parent is still staged
          expect(root.isStaged, true);

          // childA0 is unstaged
          expect(childA0.isStaged, false);

          // Children of A0 remain staged
          expect(childB.isStaged, true);
          expect(childC.isStaged, true);
        },
      );

      test(
        'If isStaged is set to false and then to true, thre previous staged child becomes staged also',
        () {
          init();

          // Currently the complete path is staged
          childC.navigateTo('.');
          expect(root.isStaged, true);
          expect(childA0.isStaged, true);
          expect(childB.isStaged, true);
          expect(childC.isStaged, true);

          // Now we unstage childB
          childA1.navigateTo('.');
          expect(childA1.isStaged, true);
          expect(childA0.isStaged, false);

          // Now we stage childB again
          childB.navigateTo('./_LAST_');

          // The previous staged children remain staged
          expect(root.isStaged, true);
          expect(childA0.isStaged, true);
          expect(childB.isStaged, true);
          expect(childC.isStaged, true);
        },
      );
    });

    // #########################################################################
    group('resetStaging(recursive)', () {
      test('should set back staging for the node and all of its children', () {
        init();

        // Stage some nodes
        childC.navigateTo('.');
        childA1.navigateTo('.');
        expect(root.isStaged, true);
        expect(childA1.isStaged, true);
        expect(childC.isStaged, true);

        // Reset staging non recursively => Only root is unstaged
        root.resetStaging(recursive: false);
        expect(root.isStaged, false);
        expect(childA1.isStaged, true);
        expect(childC.isStaged, true);

        // Reset staging recursively => All children are unstaged
        root.resetStaging(recursive: true);
        expect(root.isStaged, false);
        expect(childA1.isStaged, false);
        expect(childC.isStaged, false);

        // Also parent's stagedChild should be reset
        childC.navigateTo('.');
        expect(childB.stagedChild, childC);
        childC.resetStaging();
        expect(childB.stagedChild, null);
      });
    });

    // #########################################################################
    group('onIsStaged', () {
      test('should inform when isStaged state changes', () {
        init();
        fakeAsync((fake) {
          bool? a0IsStaged;
          final s = childA0.onIsStaged.listen((event) => a0IsStaged = event);
          fake.flushMicrotasks();
          expect(a0IsStaged, isNull);

          childC.navigateTo('.');
          expect(childC.isStaged, true);
          fake.flushMicrotasks();
          expect(a0IsStaged, isTrue);

          childA1.navigateTo('.');
          expect(childA1.isStaged, true);
          fake.flushMicrotasks();
          expect(a0IsStaged, isFalse);

          s.cancel();
        });
      });
    });

    // #########################################################################
    group('children', () {
      test('should return a list of all children', () {
        init();
        expect(root.children.toList(), [childA0, childA1, childA2]);
        expect(childA0.children.toList(), [childB]);
        expect(childB.children.toList(), [childC]);
        expect(childC.children.toList(), []);
      });
    });

    // #########################################################################
    group('findOrCreateChild(name)', () {
      test('Should return an existing child, when possible', () {
        init();
        expect(root.findOrCreateChild('child-a0'), same(childA0));
        expect(childA0.findOrCreateChild('child-b'), same(childB));
      });

      test('Should create and return a new child, when not existing', () {
        init();
        final childA1 = root.findOrCreateChild('child-a1');
        expect(childA1.name, 'child-a1');
        expect(childA1.parent, root);
        expect(root.children.length, 3);
      });

      test('Should throw an exception, if node is an index route', () {
        init();
        final indexNode = childA0.findOrCreateChild('_INDEX_');
        expect(
          () => indexNode.findOrCreateChild('xyz'),
          throwsA(
            predicate((ArgumentError f) {
              expect(
                f.message,
                'The route "${indexNode.path}" is an index routes and must not have children.',
              );
              return true;
            }),
          ),
        );
      });
    });

    // #########################################################################
    group('child(name)', () {
      test(
        'should return child with name or null if no child is existing with name',
        () {
          init();
          expect(root.child('child-a0'), childA0);
          expect(root.child('child-x'), isNull);
        },
      );
    });

    // #########################################################################
    group('hasChild(name)', () {
      test('should return when child with name exists, otherwise false', () {
        init();
        expect(root.hasChild(name: 'child-a0'), true);
        expect(root.hasChild(name: 'child-aX'), false);
      });
    });

    // #########################################################################
    group('removeChild(child)', () {
      test('removes the child from the list of childs. Disposes the child', () {
        init();
        expect(root.hasChild(name: childA0.name), isTrue);
        root.removeChild(childA0);
        expect(root.hasChild(name: childA0.name), isFalse);
      });

      test('throws an exception, if the child is not a child of node', () {
        init();
        expect(() => root.removeChild(childC), throwsArgumentError);
      });
    });

    // #########################################################################
    group('isIndexChild', () {
      test('returns false for root node', () {
        init();
        expect(root.isIndexChild, false);
      });

      test('returns true if node has no name, otherwise false', () {
        init();
        expect(childA0.findOrCreateChild('_INDEX_').isIndexChild, true);
        expect(childA0.isIndexChild, false);
      });
    });

    // #########################################################################
    group('defaultChild', () {
      test('should return null if defaultChildName is null', () {
        init();
        expect(root.defaultChild, isNull);
      });
      test(
        'should return null if defaultChildName is set, but no child with defaultChildName was created',
        () {
          init();
          root.defaultChildName = 'defaultChild';
          expect(root.defaultChild, isNull);
        },
      );

      test('should return the defaultChild if one was created before', () {
        init();
        root.defaultChildName = 'defaultChild';
        final defaultChild = root.findOrCreateChild('defaultChild');
        expect(root.defaultChild, defaultChild);
      });
    });

    // #########################################################################
    group('descendants(path)', () {
      test('should the descendants maching the path', () {
        init();
        final result = root.descendants(
          path: ['child-a0', 'child-b', 'child-c'],
        );
        expect(result, childC);
      });

      test('should create the descendants if not existing', () {
        init();
        final result = root.descendants(path: ['x', 'y']);
        expect(result.name, 'y');
        expect(result.parent!.name, 'x');
        expect(result.parent!.parent!.name, '_ROOT_');
      });

      test('should return the element itself, if path is empty', () {
        init();
        final result = root.descendants(path: []);
        expect(result, root);
      });

      test('should return the parent element, if path segment is ".."', () {
        init();
        expect(childC.descendants(path: ['..', '..']), childA0);
        expect(
          childC.descendants(path: ['..', '..', '..', 'child-a1']),
          childA1,
        );
      });

      test('should return the element itself, if path segment is "."', () {
        init();
        expect(childC.descendants(path: ['.']), childC);
        expect(childC.descendants(path: ['.', '..']), childB);
      });

      test('should throw an exception if parent is not existing', () {
        init();
        expect(() => root.descendants(path: ['..']), throwsArgumentError);
      });

      test('should ignore empty path segments', () {
        init();
        expect(root.descendants(path: ['', '', 'child-a1']), childA1);
      });

      test('path == "_LAST_" returns the staged child, when available', () {
        init();
        // Navigate childC staged -> last staged child is childC
        childC.navigateTo('.');
        expect(childC.isStaged, true);
        expect(root.descendants(path: ['_LAST_']), childC);

        // Navigate to childA1 -> last staged child childA1
        childA1.navigateTo('.');
        expect(childA0.isStaged, false);
        expect(root.descendants(path: ['_LAST_']), childA1);

        // Navigate to childA0 -> last staged child is childC again
        childA0.navigateTo('./_LAST_');
        expect(childA0.isStaged, true);
        expect(root.descendants(path: ['_LAST_']), childC);
      });

      test('path == "_LAST_" returns the default child, when available', () {
        init();

        // Navigate to root/_LAST_ -> childA0 is not staged, because no
        // defaultChildren are set.
        root.navigateTo('/_LAST_');
        expect(root.isStaged, true);
        expect(childA0.isStaged, false);

        // Init default children
        root.defaultChildName = childA0.name;
        childA0.defaultChildName = childB.name;
        childB.defaultChildName = childC.name;

        // Navigate to root/_LAST_
        root.navigateTo('_LAST_');

        // root, childA0, childB and childC should be staged because
        // default children have been set
        expect(root.isStaged, true);
        expect(childA0.isStaged, true);
        expect(childB.isStaged, true);
        expect(childC.isStaged, true);
      });
    });

    // #########################################################################
    group('ancestors(path)', () {
      test(
        'should return all ancestors started with the node itself until root',
        () {
          init();
          final ancestors = childC.ancestors;
          expect(ancestors.length, 4);
          expect(ancestors[3], root);
          expect(ancestors[2], childA0);
          expect(ancestors[1], childB);
          expect(ancestors[0], childC);
        },
      );
    });

    // #########################################################################
    group('nodeForPath(path)', () {
      test('should return the node of path relativ to own node ', () {
        init();
        expect(root.nodeForPath('/child-a0'), childA0);
        expect(childC.nodeForPath('../../../child-a0'), childA0);
        expect(childA2Index.nodeForPath('..'), root);
      });
    });

    // #########################################################################
    group('stagedChild', () {
      test('should return null, if no child is staged', () {
        init();
        expect(root.stagedChild, null);
      });

      test('should return the staged child, if one is staged', () {
        init();
        childA0.navigateTo('.');
        expect(childA0.isStaged, true);
        expect(root.stagedChild, childA0);
      });
    });

    // #########################################################################
    group('stagedChildDidChange', () {
      group('should return a steam', () {
        test('which delivers the child which became staged'
            ' or null if child became unstaged', () {
          fakeAsync((fake) {
            init();

            // Listen to stagedChildDidChange
            GgRouteTreeNode? stagedChild;
            final s = root.stagedChildDidChange.listen((c) => stagedChild = c);

            // Initially no child is staged
            fake.flushMicrotasks();
            expect(stagedChild, null);

            // Now let's make childA0 staged
            childA0.navigateTo('.');
            expect(childA0.isStaged, true);
            fake.flushMicrotasks();
            expect(stagedChild, childA0);

            // Now let's make childA1 staged
            childA1.navigateTo('.');
            expect(childA1.isStaged, true);
            fake.flushMicrotasks();
            expect(stagedChild, childA1);

            s.cancel();
          });
        });
      });
    });

    // #########################################################################
    group('stagedDescendants', () {
      test('should return a list with all staged descendants', () {
        fakeAsync((fake) {
          init();
          // Initially no child is staged
          expect(root.stagedDescendants, []);

          // Now let's set childB to staged
          childB.navigateTo('.');
          expect(childB.isStaged, true);
          fake.flushMicrotasks();

          // The complete path from root to childB should be staged
          expect(root.stagedDescendants.map((e) => e.name).toList(), [
            'child-a0',
            'child-b',
          ]);

          // The complete path from root to childB should be staged
          expect(root.stagedDescendantsInklSelf.map((e) => e.name).toList(), [
            '_ROOT_',
            'child-a0',
            'child-b',
          ]);
        });
      });
    });

    // #########################################################################
    group('needsFade, fadeInChild, fadeOutChild', () {
      test(
        'should return true for the first node that became staged or unstaged in a path',
        () {
          init();
          // Navigate to childA1 -> root should be faded in, the others not
          childA1.navigateTo('.');
          expect(root.needsFade, true);
          expect(childA1.needsFade, false);
          expect(childC.needsFade, false);
          root.needsFade = false;
          childA1.needsFade = false;

          // Navigate to childC
          // -> childA1 needs to be faded out because it is not staged anymore
          // -> childA0 needs to be faded in because it is staged now
          // -> root needs no fade, because it is already active
          // -> childB and childC need no fade, because they are not the first
          // nodes that were staged
          childC.navigateTo('.');
          expect(childA1.needsFade, true);
          expect(childA0.needsFade, true);
          expect(root.childToBeFadedIn, childA0);
          expect(root.childToBeFadedOut, childA1);

          expect(root.needsFade, false);
          expect(childB.needsFade, false);
          expect(childC.needsFade, false);

          // Navigate from child C down to child B
          // -> child C should be faded out
          childC.navigateTo('.');
          childB.needsFade = false;
          childC.needsFade = false;
          childC.navigateTo('..');
          expect(childC.needsFade, isTrue);
          expect(childC.isStaged, false);

          // Navigate from child a to root
          // -> child A should be faded out
          childA0.navigateTo('.');
          childA0.needsFade = false;
          childA0.navigateTo('..');
          expect(childA0.needsFade, isTrue);

          // Navigate from childA0 -> /
          // -> child A should be faded out
          childA0.navigateTo('.');
          childA0.needsFade = false;
          childA0.navigateTo('/');
          expect(childA0.needsFade, isTrue);
        },
      );
    });

    // #########################################################################
    group('findOrCreateParam(name, seed), param(name), hasParam(name)', () {
      test('Should create a new property, if no property with name exists', () {
        init();

        // ....................................
        // Let's create a param 'a' with seed 5
        root.findOrCreateParam(name: 'a', seed: 5);

        // ................................................................
        // Let's create the same param 'a' again, but with a different type.
        // This should give an exception.
        expect(
          () => root.findOrCreateParam(name: 'a', seed: 'Hello'),
          throwsA(
            predicate((ArgumentError e) {
              expect(
                e.message,
                'Error while retrieving param with name "a". The existing param has type "int" and not "String".',
              );
              return true;
            }),
          ),
        );

        // ......................
        // The param should exist
        expect(root.hasParam('a'), true);
        expect(root.param('a')!.value, 5);

        // ..................................................
        // Let's try to retrieve the param with a wrong type.
        // This should give an exception.
        expect(
          () => root.param<String>('a'),
          throwsA(
            predicate((ArgumentError e) {
              expect(
                e.message,
                'Error while retrieving param with name "a". The existing param has type "int" and not "String".',
              );
              return true;
            }),
          ),
        );

        // ...............................................................
        // Let's try to create a param with the name of an existing child.
        // This should give an exception.
        expect(
          () => root.findOrCreateParam(name: 'child-a0', seed: 5),
          throwsA(
            predicate((GgRouteTreeNodeError e) {
              expect(
                e.message,
                'Error: Cannot create param with name "child-a0". There is already a child node with the same name.',
              );
              return true;
            }),
          ),
        );

        // ..................................................
        // Dispose the root. This should also dispose delete all params
        root.dispose();
        expect(root.hasParam('a'), false);
      });
    });

    // #########################################################################
    group('ownOrParentParam', () {
      test(
        'should return the param with name from the node itself or its parents',
        () {
          init();
          childA0.findOrCreateParam(name: 'param', seed: 5);
          expect(childC.ownOrParentParam('param')!.value, 5);
        },
      );
    });

    // #########################################################################
    group('stagedParams', () {
      test('should return a map with all params of the staged path', () {
        init();

        // Lets define some vars
        const a0Name = 'a0';
        const a0Value = 1;

        const a1Name = 'a1';
        const a1Value = 2;

        const cName = 'c';
        const cValue = 3;

        // Initally no params should be staged
        expect(root.stagedParams, {});

        // Let's create two params, one for childA0 and childA1 and childC
        childA0.findOrCreateParam(name: a0Name, seed: a0Value);
        childA1.findOrCreateParam(name: a1Name, seed: a1Value);
        childC.findOrCreateParam(name: cName, seed: cValue);

        // root.stagedParams should sill be empty, because
        // none of the children is staged
        expect(root.stagedParams, {});

        // Let's activate childC
        childC.navigateTo('.');
        expect(childC.isStaged, true);

        // Now staged params should contain 3 and 1.
        expect(root.stagedParams.length, 2);
        expect(root.stagedParams[a0Name]?.value, a0Value);
        expect(root.stagedParams[cName]?.value, cValue);

        // Let's activate child a1
        childA1.navigateTo('.');
        expect(childA1.isStaged, true);
        expect(root.stagedParams.length, 1);
        expect(root.stagedParams[a1Name]?.value, a1Value);
      });
    });

    // #########################################################################
    group('onOwnParamChange', () {
      test('Should trigger if any of own params has changed', () {
        fakeAsync((fake) {
          init();

          // Initally the listener should not be called.
          int calls0 = 0;
          int calls1 = 0;
          resetCalls() {
            calls0 = 0;
            calls1 = 0;
          }

          final s0 = root.onOwnParamChange.listen((event) => calls0++);
          final s1 = root.onOwnParamChange.listen((event) => calls1++);
          fake.flushMicrotasks();
          expect(calls0, 0);
          expect(calls1, 0);

          // Now let's add a param. onOwnParamChange should trigger.
          root.findOrCreateParam(name: 'a', seed: 5);
          root.findOrCreateParam(name: 'b', seed: 6);

          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          // Now let's change the params. onOwnParamChange should trigger one time.
          root.param('a')!.value++;
          root.param('a')!.value++;
          root.param('b')!.value++;
          root.param('b')!.value++;
          fake.flushMicrotasks();
          expect(calls0, 1);
          expect(calls1, 1);
          resetCalls();

          s0.cancel();
          s1.cancel();
          dispose();
        });
      });
    });

    // #########################################################################
    group('onOwnOrChildParamChange', () {
      test(
        'should trigger every time an own param or an child param changes',
        () {
          fakeAsync((fake) {
            init();

            int calls0 = 0;
            int calls1 = 0;
            resetCalls() {
              calls0 = 0;
              calls1 = 0;
            }

            // Initally the listener should not be called.
            final s0 = root.onOwnOrChildParamChange.listen((event) => calls0++);
            final s1 = root.onOwnOrChildParamChange.listen((event) => calls1++);
            fake.flushMicrotasks();
            expect(calls0, 0);
            expect(calls1, 0);
            resetCalls();

            // Now lets create a param on one of the children
            childC.findOrCreateParam(name: 'x', seed: 5);
            childC.findOrCreateParam(name: 'y', seed: 'Hello');
            fake.flushMicrotasks();
            expect(calls0, 1);
            expect(calls1, 1);
            resetCalls();

            // Let's change the param on one of the children
            childC.param('x')!.value++;
            childC.param('y')!.value = 'movie';
            fake.flushMicrotasks();
            expect(calls0, 1);
            expect(calls1, 1);
            resetCalls();

            // Let's add another child, and check if changes on the new child's
            // params are communicated.
            final newChild = childC.findOrCreateChild('new-child');
            newChild.findOrCreateParam(name: 'k', seed: 5);
            fake.flushMicrotasks();
            expect(calls0, 1);
            expect(calls1, 1);
            resetCalls();
            expect(calls0, 0);
            expect(calls1, 0);
            newChild.param('k')!.value++;
            fake.flushMicrotasks();
            expect(calls0, 1);
            expect(calls1, 1);

            s0.cancel();
            s1.cancel();
          });
        },
      );
    });

    // #########################################################################
    group('get path', () {
      test('should return a list of path segments starting with the root and '
          'ending with the nodes name itself.', () {
        init();
        expect(root.pathSegments, []);
        expect(childA0.pathSegments, ['child-a0']);
        expect(childB.pathSegments, ['child-a0', 'child-b']);
        expect(childC.pathSegments, ['child-a0', 'child-b', 'child-c']);
      });
    });

    // #########################################################################
    group('get pathString', () {
      test('should return a list of path segments starting with the root and '
          'ending with the nodes name itself.', () {
        init();
        expect(root.path, '/');
        expect(childA0.path, '/child-a0');
        expect(childB.path, '/child-a0/child-b');
        expect(childC.path, '/child-a0/child-b/child-c');
      });
    });

    // #########################################################################
    group('get pathHashCode', () {
      test(
        'should return a hash which is same for all nodes having the same path ',
        () {
          init();
          expect(root.pathHashCode, root.pathHashCode);
          expect(root.pathHashCode, isNot(childA0.pathHashCode));

          final root1 = GgRouteTreeNode(name: root.name);
          expect(root.pathHashCode, root1.pathHashCode);

          final childA11 = GgRouteTreeNode(name: childA1.name, parent: root1);
          expect(childA11.pathHashCode, childA1.pathHashCode);
        },
      );
    });

    // #########################################################################
    group('get stagedChildPath', () {
      test('should return a list of path segments of staged child nodes', () {
        init();
        childC.navigateTo('.');
        expect(childC.isStaged, true);
        expect(root.stagedChildPathSegments, [
          'child-a0',
          'child-b',
          'child-c',
        ]);
        expect(childA0.stagedChildPathSegments, ['child-b', 'child-c']);
        expect(childB.stagedChildPathSegments, ['child-c']);
        expect(childC.stagedChildPathSegments, []);
      });

      test('should remove "_INDEX_" from the path', () {
        init();
        childA2Index.navigateTo('.');
        expect(root.stagedChildPath, 'child-a2');
      });
    });

    // #########################################################################
    group('set stagedChildPath', () {
      test('should activate the segments according to the assigned path', () {
        init();

        // Initially no node is staged
        expect(root.isStaged, false);
        expect(childA0.isStaged, false);
        expect(childA1.isStaged, false);
        expect(childB.isStaged, false);
        expect(childC.isStaged, false);

        // Stage all nodes in the path
        root.stagedChildPathSegments = ['child-a0', 'child-b', 'child-c'];

        expect(root.isStaged, true);
        expect(root.stagedChild, childA0);

        expect(childA0.isStaged, true);
        expect(childA0.stagedChild, childB);

        expect(childA1.isStaged, false);

        expect(childB.isStaged, true);
        expect(childB.stagedChild, childC);

        expect(childC.isStaged, true);
        expect(childC.stagedChild, null);

        // Deactivate all children
        root.stagedChildPathSegments = [];
        expect(root.isStaged, true);
        expect(childA0.isStaged, false);
        expect(childA1.isStaged, false);

        // Child B and C remain staged becaue its parent has been
        // unstaged. If we would navigate back to childB/_LAST_
        // the staged items would become visible again.
        expect(childB.isStaged, true);
        expect(childC.isStaged, true);
      });

      test('should create new child nodes, if not existing', () {
        init();
        root.stagedChildPathSegments = ['x', 'y', 'z'];
        final x = root.findOrCreateChild('x');
        final y = x.findOrCreateChild('y');
        final z = y.findOrCreateChild('z');

        expect(root.isStaged, true);
        expect(x.isStaged, true);
        expect(y.isStaged, true);
        expect(z.isStaged, true);
      });

      test('should disable children that are not selected', () {
        init();
        childC.navigateTo('.');
        expect(childC.isStaged, true);
        expect(
          root.stagedChildPathSegments.join('/'),
          'child-a0/child-b/child-c',
        );
        root.stagedChildPathSegments = ['child-a0', 'child-b'];
        expect(root.stagedChildPathSegments.join('/'), 'child-a0/child-b');
      });

      test('should handle ".." as parent segment', () {
        init();
        childC.stagedChildPathSegments = ['..', '..', '..', 'child-a1'];
        expect(root.stagedChildPathSegments.join('/'), 'child-a1');
      });

      test('should handle "." the element itself', () {
        init();
        childC.stagedChildPathSegments = ['.', '..', 'child-b'];
      });

      test('should automatically stage the _INDEX_ child when available', () {
        init();
        root.stagedChildPathSegments = ['child-a2'];
        expect(childA2.isStaged, true);
        expect(childA2Index.isStaged, true);
      });
    });

    // #########################################################################
    group('navigateTo(path)', () {
      test('Should activate the given relative path', () {
        init();
        root.navigateTo('child-a0/child-b/child-c');
        expect(root.stagedChildPath, 'child-a0/child-b/child-c');
      });

      test('Should activate the given absolute path', () {
        init();
        childC.navigateTo('/child-a1');
        expect(root.stagedChildPath, 'child-a1');
      });

      test('Should interpret ".." as parent element', () {
        init();
        childC.navigateTo('../../');
        expect(root.stagedChildPath, 'child-a0');
      });

      test('Should interpret "." as the element itself', () {
        init();
        childB.navigateTo('./child-c');
        expect(root.stagedChildPath, 'child-a0/child-b/child-c');
      });

      test('Should interpret ".." as "../../" if node is an _INDEX_ node', () {
        init();
        childA2Index.navigateTo('../');
        expect(root.stagedChildPath, '');
      });

      test('Should remove "_INDEX_" routes in path', () {
        init();
        childA2Index.navigateTo('../_INDEX_');
        expect(root.stagedChildPath, '');

        childB.navigateTo('./child-c/_INDEX_');
        expect(root.stagedChildPath, 'child-a0/child-b/child-c');

        childA2Index.navigateTo('_INDEX_/../');
        expect(root.stagedChildPath, '');
      });
    });

    // #########################################################################
    group('uriParams, uriParamForName, removeUriParamForParam', () {
      test(
        'should allow to specify default values that are used to initialize route params',
        () {
          init();

          // Let's set an early seed at the root
          root.uriParams = {'a': '10', 'b': '20invalid'};

          // The seed should be avalable on all nodes of the tree
          expect(childC.uriParamForName('a'), '10');

          expect(childB.uriParamForName('a'), '10');

          expect(root.uriParamForName('a'), '10');

          expect(childC.uriParamForName('b'), '20invalid');

          // Now lets create a paramter a
          childB.findOrCreateParam(name: 'a', seed: 11);

          // The parameter should be initialized with uriParams
          expect(childB.param('a')?.value, 10);

          // Early seed should only be used the first time.
          // Thus it should be deleted now.
          expect(root.uriParamForName('a'), null);

          // Now lets create a paramter b
          // Early seed should be ignored because it has a invalid value (20inavlid).
          childB.findOrCreateParam(name: 'b', seed: 22);
          expect(childB.param('b')?.value, 22);
        },
      );
    });

    // #########################################################################
    group('Error Handling', () {
      test('should allow to set and handle errors', () {
        init();

        // ......................................
        // Let's set an error handler on the root
        GgRouteTreeNodeError? lastErrorReceivedOnRoot;
        dynamic errorHandler(error) => lastErrorReceivedOnRoot = error;
        root.errorHandler = errorHandler;
        expect(root.errorHandler, errorHandler);

        // ............................
        // Let's set an error on childC
        final error = GgRouteTreeNodeError(
          id: 'GRC008447',
          message: 'Something went wrong.',
          node: childC,
        );
        childC.setError(error);

        // ........................................
        expect(error.toString(), 'Error GRC008447: Something went wrong.');

        // ........................................
        // It should arrive at roo'ts error handler
        expect(lastErrorReceivedOnRoot, isNotNull);
        expect(lastErrorReceivedOnRoot, error);

        // ....................................
        // Let's add an error handler to childB
        // childB should handle the error.
        // The error should not arrive at root's error handler anymore.
        lastErrorReceivedOnRoot = null;
        GgRouteTreeNodeError? lastErrorReceivedOnChildB;
        childB.errorHandler = (error) => lastErrorReceivedOnChildB = error;
        childC.setError(error);
        expect(lastErrorReceivedOnRoot, isNull);
        expect(lastErrorReceivedOnChildB, error);

        // Let's try to add an error handler twice.
        // This should cause an exception.
        expect(() => childB.errorHandler = (error) => {}, throwsArgumentError);

        // .........................................................
        // Let's remove the error handler from root and set an error
        // This should cause an exception.
        root.errorHandler = null;
        expect(() => root.setError(error), throwsException);

        // .........................
        // Assign a node to an error
        final errorWithNode = error.withNode(root);
        expect(errorWithNode.node, root);
      });
    });

    // #########################################################################
    group('set json', () {
      late GgRouteTreeNode root;
      late GgRouteTreeNode child;
      late GgRouteTreeNode grandChild;

      setUp(() {
        root = GgRouteTreeNode(name: '_ROOT_');
        root.findOrCreateParam(name: 'rootParam', seed: 1);
        child = root.findOrCreateChild('child');
        child.findOrCreateParam(name: 'childParam', seed: 1.1);
        grandChild = child.findOrCreateChild('grandChild');
        grandChild.findOrCreateParam(name: 'grandChildParam', seed: false);
      });

      test('should throw an exception if json string is invalid', () {
        expect(
          () => root.json = 'a#39f',
          throwsA(
            predicate((GgRouteTreeNodeError e) {
              expect(e.message, startsWith('Error while decoding JSON:'));
              return true;
            }),
          ),
        );
      });

      test(
        'should throw an exception if JSON contains an invalid object type',
        () {
          expect(
            () => root.json = '[]',
            throwsA(
              predicate((GgRouteTreeNodeError error) {
                expect(
                  error.message,
                  'Error while reading JSON path "/". Expected object of type Map, but got List<dynamic>.',
                );
                return true;
              }),
            ),
          );
        },
      );

      test('should throw an exception when a param has a wrong format', () {
        root.findOrCreateParam(name: 'int', seed: 10);

        expect(
          () => root.json = '{"int": "hello"}',
          throwsA(
            predicate((GgRouteTreeNodeError error) {
              expect(
                error.message,
                startsWith(
                  'Error while parsing value "hello" for attribute with name "int" on path "/":',
                ),
              );
              return true;
            }),
          ),
        );
      });

      test('should create routes contained in the JSON string', () {
        root.json = '{"a0":{}, "a1":{}}';
        expect(root.hasChild(name: 'a0'), isTrue);
        expect(root.hasChild(name: 'a1'), isTrue);
      });

      test('should directly update existing parameters', () {
        // .......................................................
        // Create four params of type int, double, bool and string
        root.findOrCreateParam(name: 'int', seed: 10);
        root.findOrCreateParam(name: 'double', seed: 11.11);
        root.findOrCreateParam(name: 'bool', seed: false);
        root.findOrCreateParam(name: 'string', seed: 'hello');

        // .......................................
        // Overwrite the existing values with JSON
        root.json =
            '{"int": 20, "double": 12.12, "bool": true, "string": "world"}';

        // ...............................................
        // Check if the params have been updated correctly
        expect(root.param('int')?.value, 20);
        expect(root.param('double')?.value, 12.12);
        expect(root.param('bool')?.value, true);
        expect(root.param('string')?.value, 'world');
      });

      test('should also parse nested structures correctly', () {
        root.json =
            '{"rootParam": 6, "child":{"childParam": 2.2, "grandChild":{"grandChildParam": true}}}';

        expect(root.param('rootParam')?.value, 6);
        expect(child.param('childParam')?.value, 2.2);
        expect(grandChild.param('grandChildParam')?.value, true);
      });

      test('should remember unknown json params for later use', () {
        root.json = '{"unknownParam": 123}';
        root.findOrCreateParam(name: 'unknownParam', seed: 5);
        expect(root.param('unknownParam')?.value, 123);
      });

      test(
        'should directly parse json params if parseAllParamsDirectly = true',
        () {
          root.parseJson(
            json: '{"unknownNum": 123}',
            parseAllParamsDirectly: true,
          );
          expect(root.param('unknownNum')?.value, 123);

          root.parseJson(
            json: '{"unknownBool": true}',
            parseAllParamsDirectly: true,
          );
          expect(root.param('unknownBool')?.value, true);

          root.parseJson(
            json: '{"unknownString": "string"}',
            parseAllParamsDirectly: true,
          );
          expect(root.param('unknownString')?.value, 'string');
        },
      );

      test('should parse semantic label', () {
        root.json = '{"__semanticLabel": "Semantic Label"}';
        expect(root.semanticLabel, 'Semantic Label');
      });
    });

    // #########################################################################
    group('get json', () {
      test('should return a JSON string of the object', () {
        final root = GgRouteTreeNode(name: '_ROOT_');
        expect(root.json, '{}');

        final child = root.findOrCreateChild('child');
        expect(root.json, '{"child":{}}');

        final grand = child.findOrCreateChild('grand');
        expect(root.json, '{"child":{"grand":{}}}');

        final parsedFoo = OtherClass();

        root.findOrCreateParam(name: 'int', seed: 5);
        child.findOrCreateParam(name: 'double', seed: 5.5);
        grand.findOrCreateParam(name: 'bool', seed: false);
        grand.findOrCreateParam(name: 'string', seed: 'hello');
        grand.findOrCreateParam(
          name: 'foo',
          seed: OtherClass(),
          stringify: (_) => 'Foo',
          parse: (_) => parsedFoo,
        );

        const expectedJson =
            '{"int":5,"child":{"double":5.5,"grand":{"bool":false,"string":"hello","foo":"Foo"}}}';
        expect(root.json, expectedJson);

        root.json = expectedJson;
        final parsedGrand = root
            .findOrCreateChild('child')
            .findOrCreateChild('grand');
        expect(parsedGrand.param('foo')?.value, parsedFoo);
      });

      test('should also save staged', () {
        final root = GgRouteTreeNode(name: '_ROOT_');
        root.navigateTo('.');
        root.navigateTo('/stagedChild');
        expect(root.findOrCreateChild('stagedChild').isStaged, true);
        final json = root.json;

        final rootCopy = GgRouteTreeNode(name: '_ROOT_');
        rootCopy.json = json;
        expect(rootCopy.stagedChild, rootCopy.findOrCreateChild('stagedChild'));
      });

      test('should also save semantic label', () {
        final root = GgRouteTreeNode(name: '_ROOT_');
        root.semanticLabel = 'ABC';
        final json = root.json;
        final rootCopy = GgRouteTreeNode(name: '_ROOT_');
        rootCopy.json = json;
        expect(rootCopy.semanticLabel, 'ABC');
      });
    });

    // #########################################################################
    group('set and get semanticLabel', () {
      test('should return the node name if no semantic label has been set', () {
        init();
        expect(childC.semanticLabel, childC.name);
        dispose();
      });

      test('should return the previously set semantic label', () {
        init();
        childC.semanticLabel = 'Child C';
        expect(childC.semanticLabel, 'Child C');
        dispose();
      });

      test('should return the the parent label for _INDEX_ routes '
          'but only when index route has not semantic label set', () {
        init();
        final index = childA0.findOrCreateChild('_INDEX_');
        expect(index.semanticLabel, childA0.semanticLabel);
        index.semanticLabel = 'Semantic Label';
        expect(index.semanticLabel, 'Semantic Label');
        dispose();
      });
    });

    // #########################################################################
    group('semanticLabelForPath', () {
      test(
        'should return the semantic label of the element relative to path',
        () {
          init();
          expect(childC.semanticLabelForPath('.'), childC.name);
          expect(childC.semanticLabelForPath('..'), childB.name);
          expect(childC.semanticLabelForPath('/'), root.name);
          expect(childC.semanticLabelForPath('../../'), childA0.name);
          dispose();
        },
      );
    });

    // #########################################################################
    group('setSemanticLabelForPath(path, label)', () {
      test('should set the semantic label of the element relative to path', () {
        init();
        childC.setSemanticLabelForPath(path: '../../', label: 'DEF');
        expect(childA0.semanticLabel, 'DEF');
        dispose();
      });
    });
  });
}
