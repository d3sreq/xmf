package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import java.util.Map
import org.eclipse.emf.common.util.DiagnosticChain
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

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
class InvariantCompilationParticipant extends AbstractMethodProcessor {
	
	override doValidate(MethodDeclaration annotatedMethod, extension ValidationContext context) {
		if(annotatedMethod.returnType != primitiveBoolean) {
			annotatedMethod.addError('''return type must be boolean in invariants («annotatedMethod.returnType.simpleName» given)''')
		}
		if(annotatedMethod.visibility != Visibility.PUBLIC) {
			annotatedMethod.addError('''Invariants must be public methods''')
		}
	}
	
	override doTransform(MutableMethodDeclaration method, extension TransformationContext context) {

		val parentClass = method.declaringType
		val validatorClass = parentClass.validatorName
		val invariantText = method.getAnnotation(Invariant).getStringValue("value")
		val errorLabelId = method.simpleName
		val validationContextVarName = parentClass.simpleName.toFirstLower

		findClass(validatorClass) => [
			addMethod('''validate_«method.declaringType.simpleName»_«method.simpleName»''') [
				returnType = primitiveBoolean
				
				addParameter(validationContextVarName, parentClass.newTypeReference)
				addParameter("diagnostics", DiagnosticChain.newTypeReference)
				addParameter("context", Map.newTypeReference(object,object))
				
				docComment = '''
					Validates the «method.simpleName» constraint of '<em>«parentClass.simpleName»</em>'.
					«method.docComment»
					<p>
						Invariant: <b>«invariantText»</b>
					</p>
					@generated'''
				body = '''
					final boolean validationResult = «validationContextVarName».«method.simpleName»();  
					if( ! validationResult ) {
						if (diagnostics != null) {
							diagnostics.add
								(createDiagnostic
									(org.eclipse.emf.common.util.Diagnostic.ERROR,
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
}