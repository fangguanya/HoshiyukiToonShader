/** アウトラインに関するヘッダ.
 *
 * @date	2018/3/1
 */
#ifndef NWH_HTS_OUTLINE_INC
#define NWH_HTS_OUTLINE_INC
#include "HoshiyukiToonCommon.cginc"

struct HTSOutlineVertData{
	float4 vertex;
	float4 worldPos;
	half4 ambientOrLightmap;
};

struct HTSOutlineFragData {
	half3 ambient;
};

/* --- Functions --- */
	HTSOutlineVertData HTS_OutlineVertexProcess(float4 vertex, half3 modelNormal, float scaleFactor) {

		HTSOutlineVertData o;
		float3		norm		= normalize( mul( (float3x3)UNITY_MATRIX_IT_MV, float4(modelNormal,0) ) );
		float2		offset		= TransformViewToProjection( norm.xy );
		float		fov			= atan( 1 / unity_CameraProjection._m11 ) * 2;
		float		edge		= scaleFactor;

		o.vertex = UnityObjectToClipPos(vertex);

		// Outline translation
		#ifdef UNITY_Z_0_FAR_FROM_CLIPSPACE
			o.vertex.xy += offset * fov * UNITY_Z_0_FAR_FROM_CLIPSPACE( o.vertex.z ) * edge;
		#else
			o.vertex.xy += offset * edge * fov * (o.vertex.z);
		#endif

		// GI Calclation
		#ifdef UNITY_LIGHT_PROBE_PROXY_VOLUME
			// Sample Light probe GI
			if (unity_ProbeVolumeParams.x != 1)
			{
				o.ambientOrLightmap.rgb = ShadeSHSimpleToon();
			}
			o.worldPos = mul( unity_ObjectToWorld, vertex );
		#else
			o.ambientOrLightmap = ShadeSHSimpleToon();
		#endif

		return o;
	}

	HTSOutlineFragData HTS_OutlineFragmentProcess(float4 worldPos, half4 ambientOrLightmap) {

		HTSOutlineFragData o;

		o.ambient = ambientOrLightmap.rgb;

		// Sample Proxy Volume GI
		#if defined(UNITY_LIGHT_PROBE_PROXY_VOLUME)
			if (unity_ProbeVolumeParams.x == 1)
			{
				o.ambient = SHEvalLinearL0L1_SampleProbeVolume_Toon( worldPos );
			}
		#endif

		return o;
	}
/* --- end --- */

#endif