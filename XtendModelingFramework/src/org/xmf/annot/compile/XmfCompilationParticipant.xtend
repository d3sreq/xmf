package org.xmf.annot.compile

import com.google.common.annotations.Beta
import java.util.List
import org.eclipse.emf.common.notify.NotificationChain
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.xmf.annot.XMF
import org.xmf.annot.XMFPackage
import org.xmf.features.FeatureFactory
import org.xmf.utils.ContextUtils

import static extension org.xmf.utils.AnnotUtils.*

@Beta
class XmfCompilationParticipant implements
	TransformationParticipant<MutableClassDeclaration> {

	override doTransform(List<? extends MutableClassDeclaration> classes, extension TransformationContext context) {
		
		val extension util = new ContextUtils(context)
		val featureFactory = new FeatureFactory(context)
		val eObjContainerType = MinimalEObjectImpl.Container.newTypeReference
		
		classes.groupBy[modelFactoryName].forEach[ fname, clist | new ModelFactoryTransformation(fname, context) => [run(clist)] ]
		classes.groupBy[modelPackageName].forEach[ pname, clist | new ModelPackageTransformation(pname, context) => [run(clist)] ]
		
		for(cls : classes) {

			// ADD: extends MinimalEObjectImpl.Container
			if( ! cls.isAssignableFrom(eObjContainerType.type)) {
				cls.extendedClass = eObjContainerType
			}
			
			// remove unnecessary annotations
			cls.annotations.filter[
				switch annotationTypeDeclaration {
					case XMF.newAnnotationReference.annotationTypeDeclaration: true
					case XMFPackage.newAnnotationReference.annotationTypeDeclaration : true
					default: false
				}
			].forEach[cls.removeAnnotation(it)]
			
			// ADD: protected EClass eStaticClass() {...}
			cls.addMethod("eStaticClass") [
				primarySourceElement = cls
				visibility = Visibility.PROTECTED
				returnType = EClass.newTypeReference
				addAnnotation(Override.newAnnotationReference)
				docComment = '''@generated'''
				body = '''return «cls.toModelPackage».eINSTANCE.«cls.toGetterName»();'''
			]

			val features = featureFactory.getAllFeatures(cls)
			
			// ADD: listing all features in the docComment of a class
			cls.docComment = '''
				A representation of the model object '<em><b>«cls.toHumanReadable»</b></em>'.
				<p>
				The following features are supported:
				«FOR feature : features BEFORE "<ul>" AFTER "</ul>"»
					<li>{@link «cls.qualifiedName»#«feature.getterName» <em>«feature.humanReadableName»</em>}</li>
				«ENDFOR»
				</p>
				@see «cls.toModelPackage.qualifiedName»#«cls.toGetterName»()
				@model kind="class"
				@generated'''
			
			// generating code for each feature
			for(feature : features) {
				
				if(feature.cachedValueInitializer != null) {
			
					// cachedValueField represents the attribute specified by the user in the code
					val cachedValueField = cls.declaredFields.findFirst[it == feature.sourceMemberDeclaration]
						?: cls.addField(feature.featureVarName)[]
						
					cachedValueField => [
						visibility = Visibility.PROTECTED
						type = feature.featureType
						primarySourceElement = cls
						docComment = '''
							The cached value of the '{@link #«feature.getterName»() <em>«feature.featureType»</em>}' containment reference.
							@see #«feature.getterName»()
							Generated using {@link «feature.class»}
							@generated'''
							
							initializer = feature.cachedValueInitializer
					]

					// always generate getter together with the cavh
					cls.addMethod(feature.getterName) [
						visibility = Visibility.PUBLIC
						returnType = feature.featureType
						body = feature.getterMethod
						primarySourceElement = feature.sourceMemberDeclaration
						docComment = '''
							Generated using {@link «feature.class»}
							@generated'''
					]
				}
									
				// optional
				if(feature.defaultValueInitializer != null) {
					cls.addField(feature.defaultValueConstantName) [
						visibility = Visibility.PROTECTED
						static = true
						final = true
						type = feature.featureType
						initializer = feature.defaultValueInitializer
						primarySourceElement = feature.sourceMemberDeclaration
						docComment = '''
							Generated using {@link «feature.class»}
							@generated'''
					]
				}
				
				// optional
				if(feature.setterMethod != null) {
					cls.addMethod(feature.setterName) [
						visibility = Visibility.PUBLIC
						addParameter("newValue", feature.featureType)
						body = feature.setterMethod
						primarySourceElement = feature.sourceMemberDeclaration
						docComment = '''
							Generated using {@link «feature.class»}
							@generated'''
					]
				}
				
				// optional
				if(feature.basicGetterMethod != null) {
					cls.addMethod(feature.basicGetterName) [
						visibility = Visibility.PUBLIC
						returnType = feature.featureType
						body = feature.basicGetterMethod
						primarySourceElement = feature.sourceMemberDeclaration
						docComment = '''
							Generated using {@link «feature.class»}
							@generated'''
					]
				}

				// optional
				if(feature.basicSetterMethod != null) {
					cls.addMethod(feature.basicSetterName) [
						visibility = Visibility.PUBLIC
						returnType = NotificationChain.newTypeReference
						addParameter("newValue", feature.featureType)
						addParameter("msgs", NotificationChain.newTypeReference)
						body = feature.basicSetterMethod
						primarySourceElement = feature.sourceMemberDeclaration
						docComment = '''
							Generated using {@link «feature.class»}
							@generated'''
					]
				}
			}

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
						«FOR feature : features »
							case «feature.globalFeatureIdConst»:
								«feature.eGet»
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
						«FOR feature : features»
							case «feature.globalFeatureIdConst»:
								«feature.eSet»
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
						«FOR feature : features»
							case «feature.globalFeatureIdConst»:
								«feature.eUnset»
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
						«FOR feature : features»
							case «feature.globalFeatureIdConst»:
								«feature.eIsSet»
						«ENDFOR»
					}
					return super.eIsSet(featureID);
				'''
			]
		}
	}
}