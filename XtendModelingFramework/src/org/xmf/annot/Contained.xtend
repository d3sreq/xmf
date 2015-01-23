package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Retention
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(FIELD)
@Retention(SOURCE)
@Active(ContainmentCompilationParticipant)
annotation Containment {}

@Beta
class ContainmentCompilationParticipant extends AbstractFieldProcessor {
	
	override doTransform(MutableFieldDeclaration annotatedField, extension TransformationContext context) {

		val parentClass = annotatedField.declaringType
		val packageName = parentClass.compilationUnit.packageName
		val packageClass = findClass('''«packageName».«packageName.toFirstUpper»Package''')
		
		val attributeName = annotatedField.simpleName.toFirstUpper
		val getter = "get" + attributeName
		val setter = "set" + attributeName
		
		annotatedField => [
			markAsRead
			visibility = Visibility.PRIVATE
			docComment = '''
				The cached value of the '{@link #«getter»() <em>«attributeName»</em>}' containment reference.
				@see #«getter»()
				@generated
				@ordered'''
		]
		
		// ADD: getter
		parentClass.addMethod(getter) [
			primarySourceElement = annotatedField
			visibility = Visibility.PUBLIC
			returnType = annotatedField.type
			body = '''return «annotatedField.simpleName»;'''
		]
		
	}
}