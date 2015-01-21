package org.xmf.annot

import com.google.common.annotations.Beta
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.impl.EFactoryImpl
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xmf.utils.AnnotUtils.*

@Beta
class ModelFactoryTransformation {

	private extension TransformationContext context
	
	private val MutableClassDeclaration packageClass
	private val MutableClassDeclaration factoryClass
	
	new(String factoryName, TransformationContext context) {
		this.context = context
		factoryClass = factoryName.findClass
		packageClass = factoryClass.modelPackageName.findClass
	}
	
	def run(Iterable<MutableClassDeclaration> classes) {
		addDocComment
		addField_eINSTANCE
		addMethod_init
		addConstructor
		addMethods_createInstance(classes)
		addMethod_create(classes)
		addMethod_getPackage
	}
	
	def addMethods_createInstance(Iterable<MutableClassDeclaration> classes) {
		for(cls : classes.filter[!abstract]) {
			factoryClass.addMethod('''create«cls.simpleName»''') [
				visibility = Visibility.PUBLIC
				returnType = cls.newTypeReference
				body = '''return new «cls.simpleName»();'''
				docComment = '''@generated'''
			]
		}
	}
	
	/** ADD: public TestikPackage getTestikPackage() */
	def addMethod_getPackage() {
		factoryClass.addMethod(packageClass.simpleName.toGetterName)[
			visibility = Visibility.PUBLIC
			returnType = packageClass.newTypeReference
			docComment = '''@generated'''
			body = '''return («packageClass.simpleName») getEPackage();'''
		]
	}
	
	/** ADD: @Override public EObject create(EClass eClass) */
	def addMethod_create(Iterable<MutableClassDeclaration> classes) {
		factoryClass.addMethod("create") [
			visibility = Visibility.PUBLIC
			returnType = EObject.newTypeReference
			addParameter("eClass", EClass.newTypeReference)
			addAnnotation(Override.newAnnotationReference)
			docComment = '''@generated'''
			body = '''
				switch (eClass.getClassifierID()) {
					«FOR cls : classes.filter[!abstract].sortBy[simpleName]»
						case «packageClass.simpleName».«cls.simpleName.toConstantName»: return create«cls.simpleName»();
					«ENDFOR»
				}
				throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
			'''
		]
	}
	
	/** ADD: constructor */
	private def addConstructor() {
		factoryClass.addConstructor [
			visibility = Visibility.PUBLIC
			docComment = '''
				Creates an instance of the factory.
				@generated'''
			body = '''super();'''
		]
	}
	
	/** ADD: public static ...Factory init() */
	private def addMethod_init() {
		factoryClass.addMethod("init") [
			visibility = Visibility.PUBLIC
			static = true
			returnType = factoryClass.newTypeReference
			docComment = '''
				Creates the default factory implementation.
				@generated'''
			body = '''
				try {
					«factoryClass.simpleName» the«factoryClass.simpleName» = («factoryClass.simpleName») org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.getEFactory(«packageClass.simpleName».eNS_URI);
					if (the«factoryClass.simpleName» != null) {
						return the«factoryClass.simpleName»;
					}
				}
				catch (Exception exception) {
					org.eclipse.emf.ecore.plugin.EcorePlugin.INSTANCE.log(exception);
				}
				return new «factoryClass.simpleName»();
			'''
		]
	}
	
	/** ADD: public static final ...Factory eINSTANCE = init(); */
	private def addField_eINSTANCE() {
		factoryClass.addField("eINSTANCE") [
			visibility = Visibility.PUBLIC
			static = true
			final = true
			type = factoryClass.newTypeReference
			docComment = '''
				The singleton instance of the factory.
				@generated'''
			initializer = '''init()'''
		]
	}
	
	private def addDocComment() {
		factoryClass => [
			docComment = '''
				The <b>Factory</b> for the model.
				It provides a create method for each non-abstract class of the model.
				@see «packageClass.qualifiedName»
				@generated'''
			extendedClass = EFactoryImpl.newTypeReference
		]
	}
	
}
