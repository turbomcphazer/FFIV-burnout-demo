// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

/*

I always liked the enemy-burnout effect from the original SNES Final Fantasy IV (or II, if you like). 
Decided to recreate it as a Unity sprite shader and it turned out to be surprisingly complex. I knew 
it started with the sprite's palette turning purple and then fading to black while lines were removed, 
but I thought the line removal was just random, one line at a time. Actually, what gives the effect a 
lot of its charm is that the lines are almost more of a dither pattern, in continuous motion. Bit 
trickier to implement, but here's my attempt.

*/

Shader "Sprites/FFIVBurnout"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 1
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
		[PerRendererData] _EnableRecolor ("Enable Recolor", Float) = 0
		[PerRendererData] _RecolorColorBlack ("RecolorColorBlack", Color) = (0,0,0,0)
		[PerRendererData] _RecolorColorWhite ("RecolorColorWhite", Color) = (0,0,0,0)
		[PerRendererData] _BurnoutValue ("BurnoutValue", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex SpriteVert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"

			fixed4 _RecolorColorBlack;
			fixed4 _RecolorColorWhite;
			float _BurnoutValue;
			float _EnableRecolor;

			float4 _MainTex_TexelSize;

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord);

				const float numLevels = 6.0; // numLevels "shades" of line-filled-ness, where 0 is "draw the whole sprite" and numLevels is "draw none of the sprite", numLevels/2 is "draw every other line"
				const float sizeBar = 12.0; // each "shade" covers this number of pixels
				const float sizeDivision = 36.0; // most visible on larger sprites, the line patterns scroll away from multiple source y-coordinates (around 3 on Golbez); this defines how spaced out those are
				const float patternSpeed = 75.0; // how fast do the dither patterns scroll

				float bv = clamp(_BurnoutValue, 0, 1);
				float y;

				float offset = (bv * sizeBar * numLevels);

				if (_EnableRecolor > 0) {

					// first we divide the sprite into horizontal divisions of sizeDivision size

					y = (IN.texcoord.y - 0.5) * _MainTex_TexelSize.w;
					if (y < 0) y--; // avert double pixel bars
					y = abs(y) % sizeDivision;

					// now we make it range out from the center

					y -= (sizeDivision / 2);
					if (y < 0) y--; // avert double pixel bars
					y = abs(y);

					// now we derive an integer value based on the y-position we're looking at and the current offset, in the range 0 - numLevels

					float curValue = (int)(((y) + (int)(offset)) / (sizeBar));

					// the middle one doesn't look very good

					if (curValue >= numLevels / 2) {
						curValue++;
					}

					// we need to clamp it because offset is allowed to start off as a negative (allowing the sprite to change palette for a moment before it starts decaying, as in the game)
					
					curValue = clamp(curValue, 0, numLevels);

					// now, in the first half of the decay, we're eliminating a line here and there--say, 1 out of every 4
					// but in the second half, we're drawing a line here and there--say, 1 out of every 4
					// so we have basically two separate modulus functions
					// there's probably a more elegant way to do this, but I don't know what it is
					// in the meantime, we have to say, if we're below halfway through this, we're removing lines, if we're above halfway through this, we're preserving lines

					curValue = numLevels - curValue;
					curValue /= numLevels;

					bool invert = false;
					bool fill = false;

					if (curValue > 0.5) { // we've passed the halfway point where we're removing only 1 out of every x lines; now we want to be keeping only 1 out of every x lines
						invert = true;
						curValue = 1 - curValue;
					}

					float fillRate = 1 / curValue;

					if (((int)(y) + (int)(bv * patternSpeed)) % fillRate < 1) { // some... math
						fill = true;
					}

					if ((fill != invert)||(bv < 0.1)) { // this line of pixels is solid, or we're just starting and haven't started burnout yet
						float brightness = dot(c.rgb, float3(0.3, 0.59, 0.11)); // calculate the brightness of the pixel
						float4 gradientColor;
						gradientColor.rgb = lerp(_RecolorColorBlack, _RecolorColorWhite,brightness); // using brightness as index, interpolate between the purple shades
						c.rgb = lerp(gradientColor.rgb, fixed4(0,0,0,0), clamp(bv - 0.1, 0, 1) * 5); // don't start fading to black until burnout effect actually starts, but then proceed quickly
					} else { // this line of pixels is empty
						c.rgba = float4(0,0,0,0);
					}
				}

				c.rgb *= IN.color;
				c.rgb *= c.a;
				return c;
			}
        ENDCG
        }
    }
}
