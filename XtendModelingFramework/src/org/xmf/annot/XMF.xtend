package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import java.util.List
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.emf.ecore.util.EObjectValidator
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xmf.annot.emf.ListAttributeFeatureTemplate
import org.xmf.annot.emf.ListContainmentFeatureTemplate
import org.xmf.annot.emf.ListReferenceFeatureTemplate
import org.xmf.annot.emf.SingleAttributeFeatureTemplate
import org.xmf.annot.emf.SingleContainmentFeatureTemplate
import org.xmf.annot.emf.SingleReferenceFeatureTemplate

import static extension org.xmf.utils.AnnotUtils.*
import org.eclipse.emf.common.util.Diagnostic

// ===============================================================================
// Active Annotation best practices
// http://mnmlst-dvlpr.blogspot.de/2013/06/active-annotation-best-practices.html
// ===============================================================================

@Beta
@Target(TYPE, PACKAGE)
@Retention(SOURCE)
@Active(XmfCompilationParticipant)
annotation XMF {}

@Beta
class XmfCompilationParticipant implements
	RegisterGlobalsParticipant<ClassDeclaration>,
	ValidationParticipant<ClassDeclaration>,
	TransformationParticipant<MutableClassDeclaration> {

// TODO: add validation: inferred types not allowed for fields and derived properties


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
		val extension util = new Util(context)
		
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
		classes.forEach[addDocCommentToClass(context)]
		
		// ADD: getters, setters and similar method for all features
		for(cls : classes) {
			val templates = cls.supportedFeatures.filter[!isDerived].map[
				switch it {
					case  isListType &&  isContainment				: new ListContainmentFeatureTemplate(it, context)
					case  isListType && !isReferenceToModelElement	: new ListAttributeFeatureTemplate(it, context)
					case  isListType &&  isReferenceToModelElement	: new ListReferenceFeatureTemplate(it, context)
					case !isListType &&  isContainment				: new SingleContainmentFeatureTemplate(it, context)
					case !isListType && !isReferenceToModelElement	: new SingleAttributeFeatureTemplate(it, context)
					case !isListType &&  isReferenceToModelElement	: new SingleReferenceFeatureTemplate(it, context)
					default: {
						addWarning(it, '''unknown specification of feature: «cls.simpleName».«it.simpleName»''')
						null
					}
				}
			].filterNull
			
			// generate getters, setters,...
			templates.forEach[generate(cls)]
			
			// ADD: @Override public void eGet(int featureID, boolean resolve, boolean coreType)
			cls.addMethod("eGet") [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				addParameter("featureID", primitiveInt)
				addParameter("resolve", primitiveBoolean)
				addParameter("coreType", primitiveBoolean)
				returnType = object
				docComment = '''@generated'''
				body = '''
					switch (featureID) {
						«FOR feature: templates »
							case «feature.globalFeatureIdConst»:
								«feature.caseBodyForEGet»
						«ENDFOR»
						}
					return super.eGet(featureID, resolve, coreType);
				'''
			]

			// ADD: @Override public void eSet(int featureID, Object newValue)
			cls.addMethod("eSet") [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				addParameter("featureID", primitiveInt)
				addParameter("newValue", object)
				docComment = '''@generated'''
				body = '''
					switch (featureID) {
						«FOR feature : templates»
							case «feature.globalFeatureIdConst»:
								«feature.caseBodyForESet»
						«ENDFOR»
					}
					super.eSet(featureID, newValue);
				'''
			]

			// ADD: @Override public void eUnset(int featureID)
			cls.addMethod("eUnset") [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				addAnnotation(Override.newAnnotationReference)
				addParameter("featureID", primitiveInt)
				docComment = '''@generated'''
				body = '''
					switch (featureID) {
						«FOR feature : templates»
							case «feature.globalFeatureIdConst»:
								«feature.caseBodyForEUnset»
						«ENDFOR»
					}
					super.eUnset(featureID);
				'''
			]

			// ADD: @Override public boolean eIsSet(int featureID)
			cls.addMethod("eIsSet") [
				primarySourceElement = cls
				visibility = Visibility.PUBLIC
				returnType = primitiveBoolean
				addAnnotation(Override.newAnnotationReference)
				addParameter("featureID", primitiveInt)
				docComment = '''@generated'''
				body = '''
					switch (featureID) {
						«FOR feature : templates»
							case «feature.globalFeatureIdConst»:
								«feature.caseBodyForEIsSet»
						«ENDFOR»
					}
					return super.eIsSet(featureID);
				'''
			]
		}

		// ADD: protected EClass eStaticClass() {...}
		for(cls : classes) {
			cls.addMethod("eStaticClass") [
				primarySourceElement = cls
				visibility = Visibility.PROTECTED
				returnType = EClass.newTypeReference
				addAnnotation(Override.newAnnotationReference)
				docComment = '''@generated'''
				body = '''return «cls.toModelPackage».eINSTANCE.«cls.toGetterName»();'''
			]
		}
	}
	
	private def addDocCommentToClass(MutableClassDeclaration cls, extension TransformationContext context) {
		val extension util = new Util(context)
		cls.docComment = '''
			A representation of the model object '<em><b>«cls.toHumanReadable»</b></em>'.
			<p>
			The following features are supported:
			«FOR feature : cls.supportedFeatures BEFORE "<ul>" AFTER "</ul>"»
				<li>{@link «cls.qualifiedName»#«feature.toGetterName» <em>«feature.toHumanReadable»</em>}</li>
			«ENDFOR»
			</p>
			@see «cls.toModelPackage.qualifiedName»#«cls.toGetterName»()
			@model kind="class"
			@generated'''
	}
	
	private def void prepareValidator(MutableClassDeclaration validatorClass, ClassDeclaration annotatedClass, extension TransformationContext context) {
		val extension util = new Util(context)
		validatorClass => [
			extendedClass = EObjectValidator.newTypeReference
			docComment = '''
				The <b>Validator</b> for the model.
				@see «validatorClass.toModelPackage.qualifiedName»
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
				initializer = '''new «validatorClass»()'''
			]
			
			// ADD: public static final String DIAGNOSTIC_SOURCE = "org.foam.ucm";
			addField("DIAGNOSTIC_SOURCE") [
				primarySourceElement = annotatedClass
				visibility = Visibility.PUBLIC
				static = true
				final = true
				type = string
				docComment = '''
					A constant for the {@link «Diagnostic.getClass.name»#getSource() source}
					of diagnostic {@link «Diagnostic.getClass.name»#getCode() codes} from this package.
					@see «Diagnostic.getClass.name»#getSource()
					@see «Diagnostic.getClass.name»#getCode()
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
				body = '''return «validatorClass.toModelPackage».eINSTANCE;'''
			]
		]
	}

	private static class Util {
		extension TransformationContext context
		val TypeReference EListType
		new(TransformationContext context) {
			this.context = context
			EListType = EList.newTypeReference
		}
		
		def toModelPackage(ClassDeclaration cls) {
			val pkg = cls.compilationUnit.packageName
			val classToFind = '''«pkg».«pkg.stringAfterLastDot.toFirstUpper»Package'''
			return classToFind.findTypeGlobally
		}
		
		/**
		 * TRUE  : EReference
		 * FALSE : EAttribute
		 */
		def boolean isReferenceToModelElement(MemberDeclaration member) {
			val typeRef = switch member {
				FieldDeclaration : member.type
				MethodDeclaration : member.returnType
				default: return false
			}
			
			if(typeRef.inferred)
				return false
			
			val typeToCheck = (typeRef.actualTypeArguments.head ?: typeRef).name.findClass
			return typeToCheck != null && typeToCheck.hasAnnotation(XMF)
		}
		
		/**
		 * TRUE  : List<Item>	which is cardinality 0..*
		 * FALSE : Item			which is cardinality 0..1
		 */
		def boolean isListType(MemberDeclaration member) {
			val typeRef = switch member {
				FieldDeclaration : member.type
				MethodDeclaration : member.returnType
				default: return false
			}
			
			if(typeRef.inferred)
				return false
				
			return typeRef.isAssignableFrom(EListType)
		}

		/**
		 * TRUE  : EReference+Containment
		 * FALSE : EReference/EAttribute without containmner
		 */
		def isContainment(MemberDeclaration member) {
			member.hasAnnotation(Contained)
		}
		
		/**
		 * TRUE  : derived feature
		 * FALSE : normal feature
		 */
		def isDerived(MemberDeclaration member) {
			member instanceof MethodDeclaration &&
			member.hasAnnotation(DerivedAttribute)
		}
	}
	
}