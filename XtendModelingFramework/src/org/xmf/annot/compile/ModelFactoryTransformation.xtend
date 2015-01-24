package org.xmf.annot.compile

import com.google.common.annotations.Beta
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.impl.EFactoryImpl
import org.eclipse.emf.ecore.plugin.EcorePlugin
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xmf.utils.AnnotUtils.*

@Beta
class ModelFactoryTransformation {

	/**
	 * This method orchestrates the content generation.
	 */
	def run(Iterable<? extends ClassDeclaration> classes) {
		addExtendsClass
		addDocComment
		addField_eINSTANCE
		addMethod_init
		addConstructor
		addMethods_createInstance(classes)
		addMethod_create(classes)
		addMethod_getPackage
	}

	private extension TransformationContext context
	
	private val ClassDeclaration packageClass
	private val MutableClassDeclaration factoryClass
	
	new(String factoryName, TransformationContext context) {
		this.context = context
		factoryClass = factoryName.findClass
		packageClass = factoryClass.modelPackageName.findClass
	}
	
	private def addExtendsClass() {
		factoryClass.extendedClass = EFactoryImpl.newTypeReference
	}
	
	private def addMethods_createInstance(Iterable<? extends ClassDeclaration> classes) {
		for(cls : classes.filter[!abstract]) {
			factoryClass.addMethod('''create«cls.simpleName»''') [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				returnType = cls.newTypeReference
				body = '''return new «cls»();'''
				docComment = '''@generated'''
			]
		}
	}
	
	/** ADD: public TestikPackage getTestikPackage() */
	private def addMethod_getPackage() {
		factoryClass.addMethod(packageClass.toGetterName)[
			primarySourceElement = packageClass
			visibility = Visibility.PUBLIC
			returnType = packageClass.newTypeReference
			docComment = '''@generated'''
			body = '''return («packageClass») getEPackage();'''
		]
	}
	
	/** ADD: @Override public EObject create(EClass eClass) */
	private def addMethod_create(Iterable<? extends ClassDeclaration> classes) {
		factoryClass.addMethod("create") [
			visibility = Visibility.PUBLIC
			returnType = EObject.newTypeReference
			addParameter("eClass", EClass.newTypeReference)
			addAnnotation(Override.newAnnotationReference)
			docComment = '''@generated'''
			body = '''
				switch (eClass.getClassifierID()) {
					«FOR cls : classes.filter[!abstract].sortBy[simpleName]»
						case «packageClass».«cls.toConstantName»: return create«cls»();
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
					«factoryClass» the«factoryClass» = («factoryClass») «EPackage.Registry».INSTANCE.getEFactory(«packageClass».eNS_URI);
					if (the«factoryClass» != null) {
						return the«factoryClass»;
					}
				}
				catch (Exception exception) {
					«EcorePlugin».INSTANCE.log(exception);
				}
				return new «factoryClass»();
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
		factoryClass.docComment = '''
			The <b>Factory</b> for the model.
			It provides a create method for each non-abstract class of the model.
			@see «packageClass.qualifiedName»
			@generated'''
	}
	
}
