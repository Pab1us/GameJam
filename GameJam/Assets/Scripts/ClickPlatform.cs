using System;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ClickPlatform : MonoBehaviour, IPointerClickHandler
{
    public GameObject platform;
    public GameObject Player;
    public float time = 0.01f;
    public Image gameover;
    public Text countCoints;
    public Image[] artifact;


    public void OnPointerClick(PointerEventData eventData)
    {
        gameObject.GetComponent<ClickPlatform>().enabled = false;
        Debug.Log(Globals.mainCharacter);
        platform.GetComponent<Animator>().enabled = true;
        countCoints.text = Globals.coins.ToString();

        if (gameObject.tag == "Coins")
        {
            if (Globals.mainCharacter == "litleMuk")
            {
                Globals.coins += 45; 
            }
            else
            {
                Globals.coins += 30;
            }
            
        }
        if (gameObject.tag == "Danger")
        {
            if (Globals.mainCharacter == "indianaJons" && Globals.saveCoin != 0)
            {
                Globals.coins = Globals.coins / 2;
                Globals.saveCoin = 0;
            }
            else if (Globals.mainCharacter == "laraCroft" && Globals.superlife != 0) 
            {
                Globals.superlife = 0;
            }
            else
            {
                if (Globals.life > 0)
                {
                    Globals.coins = 0;
                    Globals.life = 0;
                }
                else if (Globals.life == 0)
                {
                    Globals.coins = 0;
                    countCoints.text = Globals.coins.ToString();
                    gameover.gameObject.SetActive(true);
                }
                
            }
            
        }
        if (gameObject.tag == "gear")
        {
            if (Globals.mainCharacter == "litleMuk")
            {
                Globals.coins += 15;
                Globals.coins = Globals.coins * (1/2);
            }
            else
            {
                Globals.coins += 10;
            }
            
        }
   
        Debug.Log(Globals.coins);

        Player.GetComponent<Animator>().enabled = true;
        Player.GetComponent<Animator>().Play("playerAnim", -1, 0f);
        StartCoroutine(Wait(time));
    }

    private IEnumerator Wait(float time)
    {
        yield return new WaitForSeconds(time); // таймер, через 10 секунд
        Player.transform.position = gameObject.transform.position;
        Player.transform.position = new Vector3(Player.transform.position.x, -1.25f, Player.transform.position.z);
    }


    // Start is called before the first frame update
    void Start()
    {
        if (Globals.mainCharacter == "litleMuk")
        {
            for (int i = 1; i < artifact.Length; i++)
            {
                artifact[i].GetComponent<Image>().enabled = true;
            }
        }
        if (Globals.mainCharacter == "indianaJons")
        {
            for (int i = 2; i < artifact.Length; i++)
            {
                artifact[i].GetComponent<Image>().enabled = true;
            }
        }
        if (Globals.mainCharacter == "laraCroft")
        {
            for (int i = 3; i < artifact.Length; i++)
            {
                artifact[i].GetComponent<Image>().enabled = true;
            }
        }
    }





    // Update is called once per frame
    void Update()
    {
        

    }
}
