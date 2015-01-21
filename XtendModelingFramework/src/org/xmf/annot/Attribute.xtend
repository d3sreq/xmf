package org.xmf.annot

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(FIELD, METHOD)
@Active(AttributeCompilationParticipant)
@Beta
annotation Attribute {}

@Beta
class AttributeCompilationParticipant implements
	TransformationParticipant<MutableMemberDeclaration>,
	RegisterGlobalsParticipant<MemberDeclaration>,
	CodeGenerationParticipant<MemberDeclaration>,
	ValidationParticipant<MemberDeclaration>
{
	override doRegisterGlobals(List<? extends MemberDeclaration> annotatedSourceElements, extension RegisterGlobalsContext context) {}
	override doGenerateCode(List<? extends MemberDeclaration> annotatedSourceElements, extension CodeGenerationContext context) {}
	override doValidate(List<? extends MemberDeclaration> annotatedTargetElements, extension ValidationContext context) {}
	
	override doTransform(List<? extends MutableMemberDeclaration> annotatedSourceElements, extension TransformationContext context) {
		for (member : annotatedSourceElements) {
			doDispatchTransform(member, context)
		}		
	}
	
	dispatch def doDispatchTransform(MutableFieldDeclaration annotatedField, extension TransformationContext context) {
		val parentClass = annotatedField.declaringType
		val packageName = parentClass.compilationUnit.packageName
		val packageClass = findClass('''«packageName».«packageName.toFirstUpper»Package''')
		
		val attributeName = annotatedField.simpleName.toFirstUpper
		val getter = "get" + attributeName
		val setter = "set" + attributeName
		
		val defaultFieldName = attributeName.toUpperCase + "_EDEFAULT"
		val originalComment = annotatedField.docComment

		annotatedField => [
			markAsRead
			visibility = Visibility.PRIVATE
			simpleName = "_" + simpleName
			docComment = '''
				The cached value of the '{@link #«getter»() <em>«attributeName»</em>}' attribute.
				@see #«getter»()
				@generated
				@ordered'''
		]

		// ADD: protected static final String ..._EDEFAULT = ...;
		parentClass.addField(defaultFieldName) [
			primarySourceElement = annotatedField
			visibility = Visibility.PRIVATE
			static = true
			final = true
			type = annotatedField.type
			
			docComment = '''
				The default value of the '{@link #«getter»() <em>«attributeName»</em>}' attribute.
				@see #«getter»()
				@generated
				@ordered'''
			
			initializer = annotatedField.initializer
			if(initializer == null) {
				initializer = '''null'''
			}
		]

		// ADD: getter
		parentClass.addMethod(getter) [
			primarySourceElement = annotatedField
			visibility = Visibility.PUBLIC
			returnType = annotatedField.type
			docComment = '''
				Returns the value of the '<em><b>«attributeName»</b></em>' attribute.
				<p>
					«IF originalComment.isNullOrEmpty»
						If the meaning of the '<em>«attributeName»</em>' attribute isn't clear,
						there really should be more of a description here...
					«ELSE»
						«originalComment»
					«ENDIF»
				</p>
				@return the value of the '<em>«attributeName»</em>' attribute.
				@see #«setter»(String)
				@see «packageClass.qualifiedName»#get«parentClass.simpleName»_«attributeName»()
				@model id="true"
				@generated'''
			body = '''
				return «annotatedField.simpleName»;
			'''
		]
		
		// ADD: setter
		parentClass.addMethod(setter) [
			primarySourceElement = annotatedField
			visibility = Visibility.PUBLIC
			addParameter("new"+attributeName, annotatedField.type)
			docComment = '''
				Sets the value of the '{@link «parentClass.qualifiedName»#«getter» <em>«attributeName»</em>}' attribute.
				@param value the new value of the '<em>«attributeName»</em>' attribute.
				@see #get«attributeName»()
				@generated'''
			body = '''«annotatedField.simpleName» = new«attributeName»;'''
		]		
	}
	
	dispatch def doDispatchTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {
		
	}
}
