package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.DiagnosticChain
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.util.EObjectValidator
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xmf.utils.ContextUtils

import static extension org.xmf.utils.AnnotUtils.*

@Target(METHOD)
@Retention(SOURCE)
@Active(InvariantCompilationParticipant)
@Beta
annotation Invariant {
	/** Error message when violated */
	String value
}

@Beta
class InvariantCompilationParticipant implements
	RegisterGlobalsParticipant<MethodDeclaration>,
	ValidationParticipant<MethodDeclaration>,
	TransformationParticipant<MutableMethodDeclaration> {
	
	override doRegisterGlobals(List<? extends MethodDeclaration> annotatedMethods, extension RegisterGlobalsContext context) {
		// register *Validator classes
		val classesWithInvariants = annotatedMethods.map[declaringType].toSet
		classesWithInvariants.map[validatorName].forEach[registerClass]
	}
	
	override doValidate(List<? extends MethodDeclaration> annotatedMethods, extension ValidationContext context) {
		for(annotatedMethod : annotatedMethods) {
			if(annotatedMethod.returnType != primitiveBoolean) {
				annotatedMethod.addError('''return type must be boolean in invariants («annotatedMethod.returnType.simpleName» given)''')
			}
			if(annotatedMethod.visibility != Visibility.PUBLIC) {
				annotatedMethod.addError('''Invariants must be public methods''')
			}
		}
	}
	
	override doTransform(List<? extends MutableMethodDeclaration> annotatedMethods, extension TransformationContext context) {
		// optionally fill the content of the new validator class
		for(cls : annotatedMethods.map[declaringType].toSet) {
			cls.validatorName.findClass?.prepareValidator(cls, context)
		}
		// generate method for each invariant
		annotatedMethods.forEach[doTransform(context)]
	}
	
	def void doTransform(MutableMethodDeclaration method, extension TransformationContext context) {

		val parentClass = method.declaringType
		val validatorClass = parentClass.validatorName.findClass
		val invariantText = method.getAnnotation(Invariant).getStringValue("value")
		val errorLabelId = method.simpleName
		val validationContextVarName = parentClass.simpleName.toFirstLower

		validatorClass => [
			addMethod('''validate_«parentClass.simpleName»_«method.simpleName»''') [
				returnType = primitiveBoolean
				primarySourceElement = method
				
				addParameter(validationContextVarName, parentClass.newTypeReference)
				addParameter("diagnostics", DiagnosticChain.newTypeReference)
				addParameter("context", Map.newTypeReference(object,object))
				
				docComment = '''
					Validates the «method.simpleName» constraint of '<em>«parentClass.simpleName»</em>'.
					«method.docComment»
					<p>
						Invariant: <b>«invariantText»</b>
					</p>
					@generated
				'''
					
				body = '''
					final boolean validationResult = «validationContextVarName».«method.simpleName»();  
					if( ! validationResult ) {
						if (diagnostics != null) {
							diagnostics.add
								(createDiagnostic
									(«Diagnostic».ERROR,
									 DIAGNOSTIC_SOURCE,
									 0,
									 "_UI_GenericConstraint_diagnostic",
									 new Object[] { "«errorLabelId»", getObjectLabel(«validationContextVarName», context) },
									 new Object[] { «validationContextVarName» },
									 context));
						}
					}
					return validationResult;
				'''
			]
		]
	}

	private def void prepareValidator(MutableClassDeclaration validatorClass, TypeDeclaration classOrInterface, extension TransformationContext context) {
		val extension util = new ContextUtils(context)
		validatorClass => [
			primarySourceElement = classOrInterface
			extendedClass = EObjectValidator.newTypeReference
			docComment = '''
				The <b>Validator</b> for the model.
				@see «validatorClass.toModelPackage.qualifiedName»
				@generated'''
			
			// ADD: public static final UcmValidator INSTANCE = new UcmValidator();
			addField("INSTANCE") [
				primarySourceElement = classOrInterface
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
				primarySourceElement = classOrInterface
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
				primarySourceElement = classOrInterface
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
}