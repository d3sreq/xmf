package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import java.util.List
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EObjectValidator
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension org.xmf.utils.AnnotUtils.*
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.emf.ecore.EClass

// ===============================================================================
// Active Annotation best practices
// http://mnmlst-dvlpr.blogspot.de/2013/06/active-annotation-best-practices.html
// ===============================================================================

@Beta
@Target(TYPE, PACKAGE)
@Retention(SOURCE)
@Active(XClassCompilationParticipant)
annotation XMF {}

@Beta
class XClassCompilationParticipant implements
	RegisterGlobalsParticipant<ClassDeclaration>,
	ValidationParticipant<ClassDeclaration>,
	TransformationParticipant<MutableClassDeclaration> {

	override doRegisterGlobals(List<? extends ClassDeclaration> classes, extension RegisterGlobalsContext context) {
		
		// register *Validator classes
		val classesWithInvariants = classes.filter[declaredMethods.exists[hasAnnotation(Invariant)]]
		classesWithInvariants.map[validatorName].forEach[registerClass]
		
		// register *Factory
		classes.map[modelFactoryName].toSet.forEach[registerClass]
	}
	
	override doValidate(List<? extends ClassDeclaration> classes, extension ValidationContext context) {
		// validate that *Package classes exists
		classes
			.map[it -> modelPackageName] // find *Package for each class
			.filter[value == null] // find errors
			.forEach[key.addError('''Missing class «value»''')] // report errors
	}
	
	override doTransform(List<? extends MutableClassDeclaration> classes, extension TransformationContext context) {
		classes.groupBy[modelFactoryName].forEach[ fname, clist | new ModelFactoryTransformation(fname, context) => [run(clist)] ]
		classes.groupBy[modelPackageName].forEach[ pname, clist | new ModelPackageTransformation(pname, context) => [run(clist)] ]

		// optionally fill the content of the new validator class
		for(cls : classes) {
			cls.validatorName.findClass?.prepareValidator(cls, context)
		}
		
		// ADD: extends MinimalEObjectImpl.Container
		for(cls : classes) {
			// TODO: replace string comparison
			if(cls.extendedClass.name == Object.name) {
				cls.extendedClass = MinimalEObjectImpl.Container.newTypeReference
			}
		}
		
		// ADD: docComment
		for(cls : classes) {
			cls.docComment = '''
				A representation of the model object '<em><b>«cls.simpleName.toHumanReadable»</b></em>'.
				<p>
				The following features are supported:
				«FOR field : cls.supportedFeatures BEFORE "<ul>" AFTER "</ul>"»
					<li>{@link «cls.qualifiedName»#«field.simpleName.toGetterName» <em>«field.simpleName.toHumanReadable»</em>}</li>
				«ENDFOR»
				</p>
				@see «cls.modelPackageName»#«cls.simpleName.toGetterName»()
				@model kind="class"
				@generated'''
		}

		// ADD: protected EClass eStaticClass() {...}
		for(cls : classes) {
			cls.addMethod("eStaticClass") [
				primarySourceElement = cls
				visibility = Visibility.PROTECTED
				returnType = EClass.newTypeReference
				addAnnotation(Override.newAnnotationReference)
				docComment = '''@generated'''
				// TODO: eStaticClass calls api from Package which is not yet generated
				body = '''return «cls.modelPackageName».eINSTANCE.«cls.simpleName.toGetterName»();'''
			]
		}
	}
	

//	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
//
//		// ADD: @Override public Object eGet(int featureID, boolean resolve, boolean coreType)
//		annotatedClass.addMethod("eGet") [
//			primarySourceElement = annotatedClass
//			visibility = Visibility.PUBLIC
//			addAnnotation(Override.newAnnotationReference)
//			addParameter("featureID", primitiveInt)
//			addParameter("resolve", primitiveBoolean)
//			addParameter("coreType", primitiveBoolean)
//			returnType = object
//			docComment = '''@generated'''
//			body = '''
//				switch (featureID) {
//					// TODO
//«««					case TestikPackage.NAMED__NAME:
//«««						return getName();
//				}
//				return super.eGet(featureID, resolve, coreType);
//			'''
//		]
//		
//		// ADD: @Override public void eSet(int featureID, Object newValue)
//		annotatedClass.addMethod("eSet") [
//			primarySourceElement = annotatedClass
//			visibility = Visibility.PUBLIC
//			addAnnotation(Override.newAnnotationReference)
//			addParameter("featureID", primitiveInt)
//			addParameter("newValue", object)
//			docComment = '''@generated'''
//			body = '''
//				switch (featureID) {
//					// TODO
//«««					case TestikPackage.NAMED__NAME:
//«««						setName((String)newValue);
//«««						return;
//				}
//				super.eSet(featureID, newValue);
//			'''
//		]
//		
//		// ADD: @Override public void eUnset(int featureID)
//		annotatedClass.addMethod("eUnset") [
//			primarySourceElement = annotatedClass
//			visibility = Visibility.PUBLIC
//			addAnnotation(Override.newAnnotationReference)
//			addParameter("featureID", primitiveInt)
//			docComment = '''@generated'''
//			body = '''
//				switch (featureID) {
//					// TODO
//«««					case TestikPackage.NAMED__NAME:
//«««						setName(NAME_EDEFAULT);
//«««						return;
//				}
//				super.eUnset(featureID);
//			'''
//		]
//
//		// ADD: @Override public boolean eIsSet(int featureID)
//		annotatedClass.addMethod("eIsSet") [
//			primarySourceElement = annotatedClass
//			visibility = Visibility.PUBLIC
//			returnType = primitiveBoolean
//			addAnnotation(Override.newAnnotationReference)
//			addParameter("featureID", primitiveInt)
//			docComment = '''@generated'''
//			body = '''
//				switch (featureID) {
//					// TODO
//«««					case TestikPackage.NAMED__NAME:
//«««					return NAME_EDEFAULT == null ? name != null : !NAME_EDEFAULT.equals(name);
//				}
//			return super.eIsSet(featureID);
//			'''
//		]
//	}
//	
	private def void prepareValidator(MutableClassDeclaration validatorClass, ClassDeclaration annotatedClass, extension TransformationContext context) {
		validatorClass => [
			extendedClass = EObjectValidator.newTypeReference
			docComment = '''
				The <b>Validator</b> for the model.
				@see «validatorClass.modelPackageName»
				@generated'''
			
			// ADD: public static final UcmValidator INSTANCE = new UcmValidator();
			addField("INSTANCE") [
				primarySourceElement = annotatedClass
				visibility = Visibility.PUBLIC
				static = true
				final = true
				type = validatorClass.newTypeReference
				docComment = '''
					The cached model package
					@generated'''
				initializer = '''new «validatorClass.simpleName»()'''
			]
			
			// ADD: public static final String DIAGNOSTIC_SOURCE = "org.foam.ucm";
			addField("DIAGNOSTIC_SOURCE") [
				primarySourceElement = annotatedClass
				visibility = Visibility.PUBLIC
				static = true
				final = true
				type = string
				docComment = '''
					A constant for the {@link org.eclipse.emf.common.util.Diagnostic#getSource() source}
					of diagnostic {@link org.eclipse.emf.common.util.Diagnostic#getCode() codes} from this package.
					@see org.eclipse.emf.common.util.Diagnostic#getSource()
					@see org.eclipse.emf.common.util.Diagnostic#getCode()
					@generated'''
				initializer = '''"«validatorClass.compilationUnit.packageName»"'''
			]
			
			addMethod("getEPackage")[
				primarySourceElement = annotatedClass
				visibility = Visibility.PROTECTED
				returnType = EPackage.newTypeReference
				addAnnotation(Override.newAnnotationReference)
				docComment = '''
					Returns the package of this validator switch.
					@generated'''
				body = '''return «validatorClass.modelPackageName».eINSTANCE;'''
			]
		]
	}
}