using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartLevel : MonoBehaviour
{
    public GameObject nostradama;
    public GameObject laraCroft;
    public GameObject litleMuk;
    public GameObject indianaJons;
    public GameObject montyHoll;
    // Start is called before the first frame update
    void Start()
    {
        Globals.life = 1;
        if (Globals.mainCharacter == "nostradama")
        {
            nostradama.gameObject.SetActive(true);
            laraCroft.gameObject.SetActive(false);
            litleMuk.gameObject.SetActive(false);
            indianaJons.gameObject.SetActive(false);
            montyHoll.gameObject.SetActive(false);
        }
        else if (Globals.mainCharacter == "laraCroft")
        {
            nostradama.gameObject.SetActive(false);
            laraCroft.gameObject.SetActive(true);
            litleMuk.gameObject.SetActive(false);
            indianaJons.gameObject.SetActive(false);
            montyHoll.gameObject.SetActive(false);
        }
        else if (Globals.mainCharacter == "litleMuk")
        {
            nostradama.gameObject.SetActive(false);
            laraCroft.gameObject.SetActive(false);
            litleMuk.gameObject.SetActive(true);
            indianaJons.gameObject.SetActive(false);
            montyHoll.gameObject.SetActive(false);
        }
        else if (Globals.mainCharacter == "indianaJons")
        {
            nostradama.gameObject.SetActive(false);
            laraCroft.gameObject.SetActive(false);
            litleMuk.gameObject.SetActive(false);
            indianaJons.gameObject.SetActive(true);
            montyHoll.gameObject.SetActive(false);
        }
        else if (Globals.mainCharacter == "montyHoll")
        {
            nostradama.gameObject.SetActive(false);
            laraCroft.gameObject.SetActive(false);
            litleMuk.gameObject.SetActive(false);
            indianaJons.gameObject.SetActive(false);
            montyHoll.gameObject.SetActive(true);
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
