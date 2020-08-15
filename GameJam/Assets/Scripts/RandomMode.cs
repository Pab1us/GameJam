using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomMode : MonoBehaviour
{
    public GameObject[] Mods;
    private int mode;
    void Start()
    {
        //Random mode
        System.Random rand = new System.Random();
        mode = rand.Next(1, 2);

        if (mode == 1)
        {
            Mods[0].SetActive(true);
            Mods[1].SetActive(false);
            Mods[2].SetActive(false);
            Mods[3].SetActive(false);
            Mods[4].SetActive(false);
            Mods[5].SetActive(false);

        }
        else if (mode == 2)
        {
            Mods[0].SetActive(false);
            Mods[1].SetActive(true);
            Mods[2].SetActive(false);
            Mods[3].SetActive(false);
            Mods[4].SetActive(false);
            Mods[5].SetActive(false);

        }
        else if (mode == 3)
        {
            Mods[0].SetActive(false);
            Mods[1].SetActive(false);
            Mods[2].SetActive(true);
            Mods[3].SetActive(false);
            Mods[4].SetActive(false);
            Mods[5].SetActive(false);

        }
        else if (mode == 4)
        {
            Mods[0].SetActive(false);
            Mods[1].SetActive(false);
            Mods[2].SetActive(false);
            Mods[3].SetActive(true);
            Mods[4].SetActive(false);
            Mods[5].SetActive(false);

        }
        else if (mode == 5)
        {
            Mods[0].SetActive(false);
            Mods[1].SetActive(false);
            Mods[2].SetActive(false);
            Mods[3].SetActive(false);
            Mods[4].SetActive(true);
            Mods[5].SetActive(false);

        }
        else if (mode == 6)
        {
            Mods[0].SetActive(false);
            Mods[1].SetActive(false);
            Mods[2].SetActive(false);
            Mods[3].SetActive(false);
            Mods[4].SetActive(false);
            Mods[5].SetActive(true);

        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
