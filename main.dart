import 'dart:mirrors';
import 'dart:io';

main() {
  
  //Reflect class
  var reflectedClass = reflectClass(SampleClass);

  /*
  Printing all types of methods declared in Sample class
  Would also print associated class methods like toString etc
  */

  reflectedClass.instanceMembers.forEach((symbol,mirrorType) {
    if (mirrorType.isRegularMethod) {
      print(symbol);
    }
  });

  /*
  Instance mirrors reflect an instance of a Dart language object
  Can get it through reflect method
  */
  var reflectedInstance = reflect(SampleClass());

  /* 
  Type of a reflectedInstance is a ClassMirror on our class
  Hence gives access to all functions of ClassMirror as well as in above example
  */
  print(reflectedInstance.type);

  //Invoking methods through reflectedInstance
  /*
    What should be invoked is usually parameterized. Non existant method calls would invoke
    the noSuchMethod function
   */
  reflectedInstance.invoke(#methodA, []);


  //An example to invoke function through user input
  stdout.write('Enter method name: ');
  var methodName = stdin.readLineSync();
  
  //Annotation can be accessed through meta data
  //An example to parse through the class methods
  
  reflectedInstance.type.instanceMembers.forEach((_, member) {

    //Check for the actual functions only
    if (member.isOperator || !member.isRegularMethod || member.owner.simpleName != #SampleClass) return;

    var methodType = member.metadata.firstWhere((metaData) => metaData.reflectee is Methods, orElse: () => null);

    //We now have the correct associated method type
    if (methodType != null && (methodName == (methodType.reflectee as Methods).methodType)) {
      //Invoke that method
      reflectedInstance.invoke(member.simpleName, []);
    }

  });
  
}

/*
  An annotation is a form of representing syntactic metadata, a way of adding extra information
  to our code. @required @override are examples of annotations provided by dart.

  Any class can be transformed into an annotation given that you provide a const constructor for it
  
 */
//A class we will use for annotation, takes method name as argument
class Methods {
  final String methodType;

  const Methods(this.methodType);
  const Methods.a() : this('A');
  const Methods.b() : this('B');
}



//A sample class that we would reflect
class SampleClass {

  @Methods.a()
  methodA() => print('Invoked method A');

  @Methods.b()
  methodB() => print('Invoked method B');
}