/** アウトラインシェーダー.
 *
 * @date	2017/12/7
 */
Shader "HoshiyukiToon/Outline"
{
	Properties
	{
		_OutlineColor	("Outline Color", Color) = (.5,.5,.5,1)
		_OutlineSize	("Outline Width", Range(.001,.03)) = .002
	}
	SubShader
	{
		Tags {"RenderType"="Transparent" "LightMode" = "ForwardBase"}
		LOD 100

		Pass
		{
			Name "OUTLINE"
			Tags{"LightMode" = "Always" "Queue"="Transparent"}
			Cull Front
			ZWrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				//#pragma multi_compile_fwdbase
				#pragma multi_compile_fog	// make fog work
				#include "HoshiyukiToonOutline.cginc"


				/* --- Uniforms --- */
					uniform float	_OutlineSize;
					uniform fixed4	_OutlineColor;
				/* end */


				/* --- Typedef --- */
					/** 頂点入力.
					 */
					struct appdata
					{
						float4 vertex	: POSITION;
						float3 normal	: NORMAL;
					};

					/** ピクセルシェーダー入力.
					 */
					struct v2f
					{
						UNITY_FOG_COORDS(2)
						float4	vertex				: SV_POSITION;
						half4	ambientOrLightmap	: TEXCOORD0;
						float4	worldPos			: TEXCOORD1;
					};
				/* end */

				/* --- Shader Functions --- */
					/** 頂点シェーダー.
					 *
					 */
					v2f vert (appdata v)
					{
						v2f o;
						
						HTSOutlineVertData d = HTS_OutlineVertexProcess(v.vertex, v.normal, _OutlineSize);
						o.vertex			= d.vertex;
						o.worldPos			= d.worldPos;
						o.ambientOrLightmap	= d.ambientOrLightmap;

						UNITY_TRANSFER_FOG(o,o.vertex);
						return o;
					}
			
					/** フラグメントシェーダー.
					 *
					 */
					fixed4 frag (v2f i) : SV_Target
					{
						// sample the texture
						half4 col = _OutlineColor;

						HTSOutlineFragData d = HTS_OutlineFragmentProcess(i.worldPos, i.ambientOrLightmap);
						col.rgb *= d.ambient;

						// apply fog
						UNITY_APPLY_FOG(i.fogCoord, col);
						return col;
					}
				/* end */
			ENDCG
		}
	}
}
