package org.xmf.annot.emf

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.xmf.annot.DerivedAttribute
import org.xmf.annot.emf.api.Feature
import org.xmf.annot.emf.impl.ListAttribute
import org.xmf.annot.emf.impl.ListContainment
import org.xmf.annot.emf.impl.ListReference
import org.xmf.annot.emf.impl.SingleAttribute
import org.xmf.annot.emf.impl.SingleContainment
import org.xmf.annot.emf.impl.SingleReference
import org.xmf.utils.ContextUtils

import static extension org.xmf.utils.AnnotUtils.*
import org.xmf.annot.emf.impl.DerivedFeature

final class FeatureFactory {
	
	private extension val TransformationContext context
	private extension val ContextUtils utils
	
	val featureCache = <MemberDeclaration, Feature> newHashMap
	
	new(TransformationContext context) {
		this.context = context
		utils = new ContextUtils(context)
	}
	
	def getAllFeatures(TypeDeclaration typeDeclaration) {
		 
		val members =	typeDeclaration.declaredFields +
						typeDeclaration.declaredMethods.filter[hasAnnotation(DerivedAttribute)]
		
		// scan whether everything is in the cache
		val missing = members.filter[featureCache.get(it) == null]
		
		// store missing instances in cache
		missing.forEach[featureCache.put(it, toFeatureInstance)]
		
		// now retrieve everything from cache
		return members.map[featureCache.get(it)]
	}
	
	def Feature toFeatureInstance(MemberDeclaration it) {
		switch it {
			case  isDerived											: new DerivedFeature(it, context)
			case !isDerived &&  isListType &&  isContainment		: new ListContainment(it, context)
			case !isDerived &&  isListType && !isRefToModelElement	: new ListAttribute(it, context)
			case !isDerived &&  isListType &&  isRefToModelElement	: new ListReference(it, context)
			case !isDerived && !isListType &&  isContainment		: new SingleContainment(it, context)
			case !isDerived && !isListType && !isRefToModelElement	: new SingleAttribute(it, context)
			case !isDerived && !isListType &&  isRefToModelElement	: new SingleReference(it, context)
			default: throw new IllegalArgumentException("Unknown feature")
		}
	}
}