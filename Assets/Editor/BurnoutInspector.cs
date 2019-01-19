using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(BurnoutController))]
public class BurnoutInspector : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        BurnoutController myScript = (BurnoutController)target;
        if (GUILayout.Button("Swoon"))
        {
            myScript.Swoon();
        }
    }
}
