﻿Shader "Custom/voxelShader" {
	Properties {
	   _MainTex ("Base (RGB)", 2D) = "white" {}
	   _TexTiling ("TexTiling", Float) = 1
	   _OffsetX ("Offset X", Float) = 0
	   _OffsetY ("Offset Y", Float) = 0
	   _SideOffsetX ("Side Offset X", Float) = 0
	   _SideOffsetY ("Side Offset Y", Float) = 0
	   _SideTiling ("Side Tiling", Float) = 1
	   _AOtex ("AO Texture", 2D) = "white" {}
   }
   
   SubShader {
      Pass {	
         Tags { "LightMode" = "ForwardBase" } 
            // make sure that all uniforms are correctly set
 
         CGPROGRAM
         #pragma vertex vert  
         #pragma fragment frag 

         uniform float4 _LightColor0; 

         uniform half	_TexTiling;
         uniform half	_OffsetX;
         uniform half	_OffsetY;
         uniform half	_SideOffsetX;
         uniform half	_SideOffsetY;
         uniform half	_SideTiling;
         uniform sampler2D _MainTex;
         uniform sampler2D _AOtex;
         uniform float4 _MainTex_ST;

         static half3 normArray[6] = 
         {
         	half3(0,0,1), half3(0,0,-1), half3(-1,0,0), half3(1,0,0), half3(0,1,0), half3(0,-1,0)
         };

 
         struct vertexInput {
            float4 vertex : POSITION;
            half4 col	  : COLOR0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            half4 col : COLOR;
            half3 uv  : TEXCOORD0;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
 			half4 params = input.col * 255;
			uint normIndex = (uint)(params.w);
			
 			output.uv = normIndex < 2 ?  input.vertex.xyz : normIndex < 4 ? input.vertex.zyx : input.vertex.xzy;
			//HACK HACK HACK 10 is my voxel res
			output.uv = output.uv * 10;
 
            half3 normalDirection = normArray[ normIndex ];
            half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 
            half3 diffuseReflection = _LightColor0.rgb
               * max(0.0, dot(normalDirection, lightDirection)) + UNITY_LIGHTMODEL_AMBIENT;
 
 			diffuseReflection = min(diffuseReflection, 1.0);
 
            output.col = half4(diffuseReflection, params.w + 0.01);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            uint normIndex = (uint)(input.col.a);
            
			half2 tuv = input.uv.xy * (normIndex < 4 ? _SideTiling : _MainTex_ST.xy) + _MainTex_ST.zw;
			
            half2 texuv = fmod(tuv * _TexTiling,_TexTiling);
            
            if(normIndex < 4)
            	texuv += half2(_SideOffsetX,_SideOffsetY);
            else
            	texuv += half2(_OffsetX,_OffsetY);
            	
         	half4 c = tex2D(_MainTex, texuv);
         	
         	
         	half2 aouv;
         	aouv.x = (input.uv.z * 54 + normIndex * 9 +  input.uv.x) * 0.001957;
         	aouv.y = input.uv.y * 0.06667;
         	half ao = tex2D(_AOtex, aouv).a;
         	ao = 1.0 - ao * 0.5;

            return half4(input.col.rgb * ao,1.0) * c;
         }
 
         ENDCG
      }
   }
   Fallback "Mobile/Diffuse"
}
