package org.xmf.deprecated

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

@Target(FIELD)
@Active(ReferenceCompilationParticipant)
annotation Reference {}

class ReferenceCompilationParticipant extends AbstractFieldProcessor {
	override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
		val clazz = field.declaringType
		val fieldName = field.simpleName
		val fieldType = field.type
		
		// getter
		clazz.addMethod('get' + fieldName.toFirstUpper) [
			returnType = fieldType
			body = '''return this.«fieldName»;'''
			primarySourceElement = field
		]

		// setter
		clazz.addMethod('set' + fieldName.toFirstUpper) [
			addParameter(fieldName, fieldType)
			//exceptions = #[Exception.newTypeReference]
			body = '''this.«fieldName» = «fieldName»;'''
			primarySourceElement = field
		]
		
		field.markAsRead
	}
}
