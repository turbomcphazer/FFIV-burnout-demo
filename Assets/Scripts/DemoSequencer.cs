using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoSequencer : MonoBehaviour {

    public BurnoutController[] objs;
    public AudioSource fanfare;

	// Use this for initialization
	void Start () {
        StartCoroutine(SequenceBurnouts());
	}

    IEnumerator SequenceBurnouts()
    {
        int index = 0;
        float timer = 0;

        while (index < objs.Length)
        {
            objs[index].gameObject.SetActive(true);
            objs[index].Swoon();
            timer = 0;
            while (timer < 2.2f)
            {
                timer += Time.deltaTime;
                yield return null;
            }
            index++;
            yield return null;
        }

        fanfare.Play();
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
