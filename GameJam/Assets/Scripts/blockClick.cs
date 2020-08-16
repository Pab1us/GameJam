﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class blockClick : MonoBehaviour, IPointerClickHandler
{
    public GameObject[] blockPlatform;
    public GameObject[] blockNext;
    public GameObject[] blockPlatform2;
    public GameObject[] blockPlatform3;
    public GameObject[] blockPlatform4;
    public GameObject[] blockPlatform5;
    public GameObject[] blockPlatform6;
    public GameObject[] blockPlatform7;
    public GameObject[] blockPlatform8;
    public GameObject[] blockPlatform9;
    public GameObject[] blockPlatform10;

    public void OnPointerClick(PointerEventData eventData)
    {
        checkBlock();
 
        gameObject.GetComponent<ClickPlatform>().enabled = false;
        Debug.Log(Globals.coins);
      
    }


    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < blockPlatform.Length; i++)
        {
            blockPlatform[i].GetComponent<ClickPlatform>().enabled = true;
        }
        
        for (int i = 1; i < blockNext.Length; i++)
        {
            blockNext[i].GetComponent<ClickPlatform>().enabled = false;
        }
    }


    private void checkBlock()
    {
        if (Globals.count == 1)
        {
            for (int i = 0; i < blockPlatform2.Length; i++)
            {
                blockPlatform2[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 2)
        {
            for (int i = 0; i < blockPlatform3.Length; i++)
            {
                blockPlatform3[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform2[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 3)
        {
            for (int i = 0; i < blockPlatform4.Length; i++)
            {
                blockPlatform4[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform3[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 4)
        {
            for (int i = 0; i < blockPlatform5.Length; i++)
            {
                blockPlatform5[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform4[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 5)
        {
            for (int i = 0; i < blockPlatform6.Length; i++)
            {
                blockPlatform6[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform5[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 6)
        {
            for (int i = 0; i < blockPlatform7.Length; i++)
            {
                blockPlatform7[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform6[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 7)
        {
            for (int i = 0; i < blockPlatform8.Length; i++)
            {
                blockPlatform8[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform7[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 8)
        {
            for (int i = 0; i < blockPlatform9.Length; i++)
            {
                blockPlatform9[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform8[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }
        else if (Globals.count == 9)
        {
            for (int i = 0; i < blockPlatform10.Length; i++)
            {
                blockPlatform10[i].GetComponent<ClickPlatform>().enabled = true;
                blockPlatform9[i].GetComponent<ClickPlatform>().enabled = false;
            }
        }

    }




    // Update is called once per frame
    void Update()
    {


    }
}
