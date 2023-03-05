// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AxisGames/Shaders/Teleport"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Tint("Tint", Color) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_Metalic("Metalic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_NormalMap("Normal Map", 2D) = "bump" {}
		_AmbiantOcculsion("Ambiant Occulsion", 2D) = "white" {}
		[HDR]_GlowColor("Glow Color", Color) = (0,1.372549,2,0)
		_Teleport("Teleport", Range( -20 , 20)) = 0
		[Toggle]_Reverse("Reverse", Float) = 0
		_Tiling("Tiling", Vector) = (5,5,0,0)
		_VertOffsetStrength("VertOffset Strength", Float) = 0
		_Noise1Speed("Noise 1 Speed", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _Teleport;
		uniform float _Reverse;
		uniform float _VertOffsetStrength;
		uniform float2 _Tiling;
		uniform float _Noise1Speed;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _AmbiantOcculsion;
		uniform float4 _AmbiantOcculsion_ST;
		uniform float4 _Tint;
		uniform float4 _GlowColor;
		uniform float _Metalic;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform23 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float Y_Gradiant17 = saturate( ( ( transform23.y + _Teleport ) / (( _Reverse )?( 10.0 ):( -10.0 )) ) );
			float2 panner89 = ( ( _Time.y * _Noise1Speed ) * float2( 0,-1 ) + float2( 0,0 ));
			float2 uv_TexCoord88 = v.texcoord.xy * _Tiling + panner89;
			float simplePerlin2D96 = snoise( uv_TexCoord88 );
			simplePerlin2D96 = simplePerlin2D96*0.5 + 0.5;
			float Noise11 = simplePerlin2D96;
			float3 VertOffset64 = ( ( ( ase_vertex3Pos * Y_Gradiant17 ) * _VertOffsetStrength ) * Noise11 );
			v.vertex.xyz += VertOffset64;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 NormalMap55 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			o.Normal = NormalMap55;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float2 uv_AmbiantOcculsion = i.uv_texcoord * _AmbiantOcculsion_ST.xy + _AmbiantOcculsion_ST.zw;
			float4 Albedo53 = ( tex2D( _Albedo, uv_Albedo ) * tex2D( _AmbiantOcculsion, uv_AmbiantOcculsion ) * _Tint );
			o.Albedo = Albedo53.rgb;
			float2 panner89 = ( ( _Time.y * _Noise1Speed ) * float2( 0,-1 ) + float2( 0,0 ));
			float2 uv_TexCoord88 = i.uv_texcoord * _Tiling + panner89;
			float simplePerlin2D96 = snoise( uv_TexCoord88 );
			simplePerlin2D96 = simplePerlin2D96*0.5 + 0.5;
			float Noise11 = simplePerlin2D96;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform23 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float Y_Gradiant17 = saturate( ( ( transform23.y + _Teleport ) / (( _Reverse )?( 10.0 ):( -10.0 )) ) );
			float4 Emmision43 = ( _GlowColor * ( Noise11 * Y_Gradiant17 ) );
			o.Emission = Emmision43.rgb;
			o.Metallic = _Metalic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			float temp_output_34_0 = ( Y_Gradiant17 * 1.0 );
			float OpacityMask31 = ( ( ( ( 1.0 - Y_Gradiant17 ) * Noise11 ) - temp_output_34_0 ) + ( 1.0 - temp_output_34_0 ) );
			clip( OpacityMask31 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;100;-5695.778,-4224.316;Inherit;False;3239.208;2759.511;Comment;3;13;97;99;Noises;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;99;-3426.869,-3100.246;Inherit;False;598.9067;389.314;Comment;1;11;Noise Output;0.6179246,1,0.6645728,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-5438.317,-3667.931;Inherit;False;1909.317;609.7148;Comment;7;89;96;95;94;93;92;88;Shred Noise ;0.4103774,0.698967,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;72;-950.0917,-614.29;Inherit;False;1145.906;640.8099;Comment;8;61;62;69;63;68;70;71;64;Vertex Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;60;-969.0277,-1641.257;Inherit;False;881.3955;914.1787;Comment;7;50;51;49;52;53;55;54;Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-2222.725,-1785.883;Inherit;False;1131.91;552.9769;Comment;6;39;40;42;43;46;47;Emmision;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2498.437,-949.5902;Inherit;False;1363.96;776.6541;Comment;10;22;28;29;30;34;33;35;36;37;31;Opacity Mask;0.8690699,0.990566,0.6120951,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-4289.614,-913.9498;Inherit;False;1716.361;681.3588;Comment;10;15;14;23;24;17;26;25;16;73;74;Y_Gradiant;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-5437.41,-2709.664;Inherit;False;1920.453;804.4683;Comment;9;82;81;86;83;84;87;85;75;1;Strips Noise;0.6185475,0.9433962,0.9414388,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-3682.704,-727.9148;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;14;-4239.614,-863.9496;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;23;-3962.56,-829.3223;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-3395.251,-659.6417;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;-3125.758,-643.1357;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-4113.245,-655.8127;Inherit;True;Property;_Teleport;Teleport;8;0;Create;True;0;0;0;False;0;False;0;0;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2884.266,-734.2475;Inherit;True;Y_Gradiant;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-2448.437,-897.9692;Inherit;True;17;Y_Gradiant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-2205.26,-899.5902;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1981.889,-896.9092;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-2235.035,-683.5493;Inherit;True;11;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2211.906,-480.275;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-2448.023,-537.8051;Inherit;True;17;Y_Gradiant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1758.106,-646.9315;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;36;-1755.952,-426.9364;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1513.991,-494.7491;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1358.477,-578.7425;Inherit;True;OpacityMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-2170.721,-1654.814;Inherit;True;11;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-2172.725,-1462.906;Inherit;True;17;Y_Gradiant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1912.964,-1556.212;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1314.815,-1650.214;Inherit;True;Emmision;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;-1909.754,-1735.883;Inherit;False;Property;_GlowColor;Glow Color;7;1;[HDR];Create;True;0;0;0;False;0;False;0,1.372549,2,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1653.509,-1583.386;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-919.0278,-1153.05;Inherit;True;Property;_AmbiantOcculsion;Ambiant Occulsion;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-496.8922,-1190.38;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;49;-872.6378,-939.0796;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;-915.8342,-1365.662;Inherit;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-311.6318,-1225.062;Inherit;True;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1083.107,-1300.308;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AxisGames/Shaders/Teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;False;Transparent;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;758.3139,-1430.868;Inherit;True;53;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;754.5231,-1050.71;Inherit;True;43;Emmision;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;756.2635,-1241.652;Inherit;True;55;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;755.1874,-859.4302;Inherit;True;31;OpacityMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;395.4836,-1113.043;Inherit;True;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-585.9841,-1548.445;Inherit;True;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;54;-916.6106,-1591.258;Inherit;True;Property;_NormalMap;Normal Map;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;758.1938,-662.5039;Inherit;True;64;VertOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;58;395.9435,-1340.087;Inherit;True;Property;_Metalic;Metalic;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;61;-900.0917,-564.29;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;62;-893.772,-368.9959;Inherit;True;17;Y_Gradiant;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-379.5617,-323.6944;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-635.4418,-458.8437;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-638.9217,-243.4151;Inherit;True;Property;_VertOffsetStrength;VertOffset Strength;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-190.8596,-285.3801;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-402.7596,-203.4802;Inherit;True;11;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-28.18564,-353.5949;Inherit;True;VertOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-3829.74,-427.7031;Inherit;False;Constant;_NegativeNumber;Negative Number;10;0;Create;True;0;0;0;False;0;False;-10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-3828.316,-336.3594;Inherit;False;Constant;_PositiveNumber;Positive Number;13;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;74;-3601.326,-407.5859;Inherit;False;Property;_Reverse;Reverse;9;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-4466.238,-2567.379;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;75;-4151.518,-2551.758;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;85;-5175.237,-2442.835;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-4969.197,-2300.38;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;84;-4724.767,-2240.945;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-4723.726,-2498.083;Inherit;True;Property;_NoiseSclae;Noise Sclae;12;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-4534.142,-3530.793;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;93;-5387.367,-3614.313;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-5164.341,-3473.961;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;96;-4287.763,-3545.675;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;89;-4840.693,-3309.623;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;92;-4767.745,-3617.931;Inherit;True;Property;_Tiling;Tiling;10;0;Create;True;0;0;0;False;0;False;5,5;50,50;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;94;-5388.317,-3399.427;Inherit;True;Property;_Noise1Speed;Noise 1 Speed;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-5177.717,-2205.669;Inherit;True;Property;_Noise2Speed;Noise 2 Speed;15;0;Create;True;0;0;0;False;0;False;1.37;1.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;81;-3942.702,-2407.745;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-4154.923,-2277.702;Inherit;True;Property;_Trikness;Trikness;13;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3238.145,-3006.438;Float;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;15;0;23;2
WireConnection;15;1;16;0
WireConnection;23;0;14;0
WireConnection;24;0;15;0
WireConnection;24;1;74;0
WireConnection;26;0;24;0
WireConnection;17;0;26;0
WireConnection;28;0;22;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;34;0;33;0
WireConnection;35;0;29;0
WireConnection;35;1;34;0
WireConnection;36;0;34;0
WireConnection;37;0;35;0
WireConnection;37;1;36;0
WireConnection;31;0;37;0
WireConnection;42;0;39;0
WireConnection;42;1;40;0
WireConnection;43;0;47;0
WireConnection;47;0;46;0
WireConnection;47;1;42;0
WireConnection;51;0;52;0
WireConnection;51;1;50;0
WireConnection;51;2;49;0
WireConnection;53;0;51;0
WireConnection;0;0;32;0
WireConnection;0;1;56;0
WireConnection;0;2;12;0
WireConnection;0;3;58;0
WireConnection;0;4;59;0
WireConnection;0;10;44;0
WireConnection;0;11;65;0
WireConnection;55;0;54;0
WireConnection;69;0;63;0
WireConnection;69;1;68;0
WireConnection;63;0;61;0
WireConnection;63;1;62;0
WireConnection;70;0;69;0
WireConnection;70;1;71;0
WireConnection;64;0;70;0
WireConnection;74;0;25;0
WireConnection;74;1;73;0
WireConnection;1;0;83;0
WireConnection;1;1;84;0
WireConnection;75;0;1;2
WireConnection;87;0;85;0
WireConnection;87;1;86;0
WireConnection;84;1;87;0
WireConnection;88;0;92;0
WireConnection;88;1;89;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;96;0;88;0
WireConnection;89;1;95;0
WireConnection;81;0;75;0
WireConnection;81;1;82;0
WireConnection;11;0;96;0
ASEEND*/
//CHKSM=60BFD2B1E338CD053D23E26B10CEFF2226AC20F1