using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomPlatform : MonoBehaviour
{
    public GameObject[] platforms;
    private int mode;
    // Start is called before the first frame update
    void Start()
    {
        //Random mode
        System.Random rand = new System.Random();
        mode = rand.Next(1, 6);
 
        for (int i = platforms.Length - 1; i >= 1; i--) // Перемешиваем массив
        {
            int j = rand.Next(i + 1);
            // обменять значения data[j] и data[i]
            var temp = platforms[j];
            platforms[j] = platforms[i];
            platforms[i] = temp;
        }
        for (int i = 0; i < 6; i++) //Назначаю координаты
        {
            if (i==0)
            {
                platforms[i].transform.position = new Vector3(0, 0, -3.9f);
            }
            else if (i == 1)
            {
                platforms[i].transform.position = new Vector3(0, 0, -2.6f);
            }
            else if (i == 2)
            {
                platforms[i].transform.position = new Vector3(0, 0, -1.3f);
            }
            else if (i == 3)
            {
                platforms[i].transform.position = new Vector3(0, 0, 0);
            }
            else if (i == 4)
            {
                platforms[i].transform.position = new Vector3(0, 0, 1.3f);
            }
            else if (i == 5)
            {
                platforms[i].transform.position = new Vector3(0, 0, 2.6f);
            }
            else if (i == 6)
            {
                platforms[i].transform.position = new Vector3(0, 0, 3.9f);
            }


        }
        
        //if (mode == 1)
        //{
        //    platforms[0].SetActive(true);
        //    platforms[1].SetActive(false);
        //    platforms[2].SetActive(false);
        //    platforms[3].SetActive(false);
        //    platforms[4].SetActive(false);
        //    platforms[5].SetActive(false);

        //} else if (mode == 2)
        //{
        //    platforms[0].SetActive(false);
        //    platforms[1].SetActive(true);
        //    platforms[2].SetActive(false);
        //    platforms[3].SetActive(false);
        //    platforms[4].SetActive(false);
        //    platforms[5].SetActive(false);

        //} else if (mode == 3)
        //{
        //    platforms[0].SetActive(false);
        //    platforms[1].SetActive(false);
        //    platforms[2].SetActive(true);
        //    platforms[3].SetActive(false);
        //    platforms[4].SetActive(false);
        //    platforms[5].SetActive(false);

        //}else if (mode == 4)
        //{
        //    platforms[0].SetActive(false);
        //    platforms[1].SetActive(false);
        //    platforms[2].SetActive(false);
        //    platforms[3].SetActive(true);
        //    platforms[4].SetActive(false);
        //    platforms[5].SetActive(false);

        //}else if (mode == 5)
        //{
        //    platforms[0].SetActive(false);
        //    platforms[1].SetActive(false);
        //    platforms[2].SetActive(false);
        //    platforms[3].SetActive(false);
        //    platforms[4].SetActive(true);
        //    platforms[5].SetActive(false);

        //}else if (mode == 6)
        //{
        //    platforms[0].SetActive(false);
        //    platforms[1].SetActive(false);
        //    platforms[2].SetActive(false);
        //    platforms[3].SetActive(false);
        //    platforms[4].SetActive(false);
        //    platforms[5].SetActive(true);

        //}

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
