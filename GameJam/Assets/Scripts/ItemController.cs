using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ItemController : MonoBehaviour
{
    public Sprite litleMuk;
    public Sprite indianaJons;
    public Sprite laraCroft;
    public Sprite montyHoll;
    public Sprite nostradama;
    private int characterCount;
    private Sprite mainCharacter;
    public int skill;
    public double coin = 100;
    // Start is called before the first frame update
    void Start()
    {
        System.Random rand = new System.Random();
        characterCount = rand.Next(1, 1);
        if (characterCount == 1)
        {
            mainCharacter = litleMuk;
            coin = coin * 1.5;
        }
        if (characterCount == 2)
        {
            mainCharacter = indianaJons;
        }
        if (characterCount == 3)
        {
            mainCharacter = laraCroft;
        }
        if (characterCount == 4)
        {
            mainCharacter = montyHoll;
        }
        if (characterCount == 5)
        {
            mainCharacter = nostradama;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
