package org.xmf.annot.emf

import org.eclipse.emf.common.notify.NotificationChain
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

import static extension org.xmf.utils.AnnotUtils.*

abstract class AbstractFeatureTemplate {

	protected extension TransformationContext context
	private MemberDeclaration featureRelatedMember 
	
	new(MemberDeclaration featureRelatedMember, TransformationContext context) {
		this.context = context
		this.featureRelatedMember = featureRelatedMember
	}

	final def void generate(MutableClassDeclaration cls) {

		// optional
		if(bodyOfDefaultConst != null) {
			cls.addField(defaultValueConst) [
				visibility = Visibility.PROTECTED
				static = true
				final = true
				type = featureType
				initializer = bodyOfDefaultConst
				primarySourceElement = cls
				docComment = '''
					Generated using {@link «this.class»}
					@generated'''
			]
		}

		// always generated: cached value
		val cachedValueField = cls.declaredFields.findFirst[simpleName == featureVarName] ?: cls.addField(featureVarName)[]
		println(cachedValueField)
		cachedValueField => [
			visibility = Visibility.PROTECTED
			type = featureType
			primarySourceElement = cls
			docComment = '''
				The cached value of the '{@link #«getterName»() <em>«featureType.toHumanReadable»</em>}' containment reference.
				@see #«getterName»()
				Generated using {@link «this.class»}
				@generated'''
				
			if(bodyOfCachedValue != null)
				initializer = bodyOfCachedValue
		]

		// always generated: getter
		cls.addMethod(getterName) [
			visibility = Visibility.PUBLIC
			returnType = featureType
			body = bodyOfGetter
			primarySourceElement = cls
			docComment = '''
				Generated using {@link «this.class»}
				@generated'''
		]

		// optional
		if(bodyOfSetter != null) {
			cls.addMethod(setterName) [
				visibility = Visibility.PUBLIC
				addParameter("newValue", featureType)
				body = bodyOfSetter
				primarySourceElement = cls
				docComment = '''
					Generated using {@link «this.class»}
					@generated'''
			]
		}
		
		// optional
		if(bodyOfBasicGetter != null) {
			cls.addMethod(basicGetterName) [
				visibility = Visibility.PUBLIC
				returnType = featureType
				body = bodyOfBasicGetter
				primarySourceElement = cls
				docComment = '''
					Generated using {@link «this.class»}
					@generated'''
			]
		}

		// optional
		if(bodyOfBasicSetter != null) {
			cls.addMethod(basicSetterName) [
				visibility = Visibility.PUBLIC
				returnType = NotificationChain.newTypeReference
				addParameter("newValue", featureType)
				addParameter("msgs", NotificationChain.newTypeReference)
				body = bodyOfBasicSetter
				primarySourceElement = cls
				docComment = '''
					Generated using {@link «this.class»}
					@generated'''
			]
		}
	}

	// useful variables used inside the templates (should not override)
	final protected def String getDefaultValueConst() {featureRelatedMember.toEDEFAULT}
	final protected def TypeReference getFeatureType() {featureRelatedMember.toType}
	final protected def TypeReference getFeatureItemType() {getFeatureType.actualTypeArguments.head}
	final protected def String getFeatureVarName() {featureRelatedMember.simpleName}
	final protected def String getGetterName() {featureRelatedMember.toGetterName}
	final protected def String getSetterName() {featureRelatedMember.toSetterName}
	final protected def String getBasicGetterName() '''basic«getterName.toFirstUpper»'''
	final protected def String getBasicSetterName() '''basic«setterName.toFirstUpper»'''
	final def String getGlobalFeatureIdConst() {featureRelatedMember.toGlobalFeatureIdConst}
	
	// templates for various method bodies (override if necessary)
	protected def StringConcatenationClient getBodyOfCachedValue() {null}
	protected def StringConcatenationClient getBodyOfGetter() {null}
	protected def StringConcatenationClient getBodyOfDefaultConst() {null}
	protected def StringConcatenationClient getBodyOfSetter() {null}
	protected def StringConcatenationClient getBodyOfBasicGetter() {null}
	protected def StringConcatenationClient getBodyOfBasicSetter() {null}
	
	// templates for various switch cases (override if necessary)
	def StringConcatenationClient getCaseBodyForEInverseRemove() {null}
	def StringConcatenationClient getCaseBodyForEGet() {null}
	def StringConcatenationClient getCaseBodyForESet() {null}
	def StringConcatenationClient getCaseBodyForEUnset() {null}
	def StringConcatenationClient getCaseBodyForEIsSet() {null}
}