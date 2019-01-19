using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BurnoutController : MonoBehaviour {

    public class RecolorColor
    {
        public Color cBlack;
        public Color cWhite;

        public RecolorColor(Color cB, Color cW)
        {
            cBlack = cB;
            cWhite = cW;
        }
    }

    public Color cBlack;
    public Color cWhite;
    public Renderer rend;

    [Range(-0.2f,1)]
    public float t = -0.2f;
    bool started = false;

    private void Start()
    {
        rend = GetComponent<Renderer>();
        if (rend == null)
        {
            rend = GetComponentInChildren<Renderer>();
        }
    }

    public RecolorColor GetRecolorGradient()
    {
        return new RecolorColor(cBlack, cWhite);
    }

    public void SetRecolorGradient(RecolorColor RC)
    {
        cBlack = RC.cBlack;
        cWhite = RC.cWhite;

        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        rend.GetPropertyBlock(mpb);
        mpb.SetColor("_RecolorColorBlack", cBlack);
        mpb.SetColor("_RecolorColorWhite", cWhite);
        mpb.SetFloat("_EnableRecolor", 1);
        rend.SetPropertyBlock(mpb);
    }

    public void DisableRecolorGradient()
    {
        cBlack = new Color(0, 0, 0, 0);

        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        rend.GetPropertyBlock(mpb);
        mpb.SetFloat("_EnableRecolor", 0f);
        rend.SetPropertyBlock(mpb);
    }

    public void Swoon()
    {
        t = -0.2f;
        started = true;
    }

    public void SetBurnoutValue(float val)
    {
        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        rend.GetPropertyBlock(mpb);
        mpb.SetFloat("_BurnoutValue", val);
        rend.SetPropertyBlock(mpb);
    }

    private void Update()
    {
        if ((started) ||(t > -0.2f))
        {
            SetBurnoutValue(t);

            if ((t < 0) && (t + Time.deltaTime >= 0))
            {
                if (GetComponent<AudioSource>() != null)
                {
                    GetComponent<AudioSource>().Play();
                }
                SetRecolorGradient(new RecolorColor(cBlack, cWhite));
            }

            if (started)
            {
                t += Time.deltaTime * 0.5f;
                if (t > 1)
                {
                    t = 1;
                    started = false;
                }
            }

        }

        if (t == -0.2f)
        {
            DisableRecolorGradient();
        }
    }
}
